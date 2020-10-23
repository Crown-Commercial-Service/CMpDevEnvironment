data "aws_iam_role" "cmp_terraform_codepipeline_role" {
  name = var.codepipeline_iam_role_name
}

data "aws_iam_role" "cmp_terraform_codebuild_role" {
  name = var.codebuild_iam_role_name
}

data "aws_ssm_parameter" "github_token" {
  name = var.github_token_alias
}

data "aws_s3_bucket" "artifact_bucket" {
  bucket = local.artifact_bucket_name
}

module "codebuild" {
  source                     = "../../modules/codebuild"
  artifacts_type             = var.codebuild_terraform_plan_artifact_type
  bootstrap_directory        = var.bootstrap_directory
  bootstrap_tfplan_filename  = var.bootstrap_tfplan_filename
  cloudwatch_logs_group_name = var.codebuild_terraform_plan_cloudwatch_logs_group_name
  codebuild_project_name     = var.codebuild_terraform_plan_project_name
  codebuild_service_role     = data.aws_iam_role.cmp_terraform_codebuild_role.arn
  environment_compute_type   = var.codebuild_terraform_plan_environment_compute_type
  environment_image          = var.codebuild_terraform_plan_environment_image
  environment_type           = var.codebuild_terraform_plan_environment_type
  source_buildspec_filepath  = var.codebuild_terraform_plan_source_buildspec_filepath
  source_type                = var.codebuild_terraform_plan_source_type
}

resource "aws_codepipeline" "cmp_dev_environment_pipeline" {
  name     = var.codepipeline_name
  role_arn = data.aws_iam_role.cmp_terraform_codepipeline_role.arn

  artifact_store {
    location = data.aws_s3_bucket.artifact_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category         = "Source"
      name             = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = [var.source_artifact]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repository
        Branch     = var.github_branch
        OAuthToken = data.aws_ssm_parameter.github_token.value
      }
    }
  }

  stage {
    name = "Terraform-Plan"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = [var.source_artifact]
      output_artifacts = [var.terraform_plan_artifact]
      version          = "1"

      configuration = {
        ProjectName = var.codebuild_terraform_plan_project_name
      }
    }
  }
}
