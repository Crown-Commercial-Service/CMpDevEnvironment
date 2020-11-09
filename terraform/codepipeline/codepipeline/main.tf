data "aws_iam_role" "cmp_terraform_codepipeline_role" {
  name = "${var.codepipeline_iam_role_name}"
}

data "aws_iam_role" "cmp_terraform_codebuild_role" {
  name = "${var.codebuild_iam_role_name}"
}

data "aws_ssm_parameter" "github_token" {
  name = "${var.github_token_alias}"
}

data "aws_s3_bucket" "artifact_bucket" {
  bucket = "${local.artifact_bucket_name}"
}

module "codebuild" {
  source                                           = "../../modules/codebuild"
  artifacts_type                                   = "${var.codebuild_terraform_plan_artifact_type}"
  bootstrap_directory                              = "${var.bootstrap_directory}"
  bootstrap_tfplan_filename                        = "${var.bootstrap_tfplan_filename}"
  build_api1_directory                             = "${var.build_api1_directory}"
  build_api1_tfplan_filename                       = "${var.build_api1_tfplan_filename}"
  build_api2_directory                             = "${var.build_api2_directory}"
  build_api2_tfplan_filename                       = "${var.build_api2_tfplan_filename}"
  build_app1_directory                             = "${var.build_app1_directory}"
  build_app1_tfplan_filename                       = "${var.build_app1_tfplan_filename}"
  build_app2_directory                             = "${var.build_app2_directory}"
  build_app2_tfplan_filename                       = "${var.build_app2_tfplan_filename}"
  build_cmp_maintenance_directory                  = "${var.build_cmp_maintenance_directory}"
  build_cmp_maintenance_tfplan_filename            = "${var.build_cmp_maintenance_tfplan_filename}"
  build_crown_marketplace_directory                = "${var.build_crown_marketplace_directory}"
  build_crown_marketplace_legacy_directory         = "${var.build_crown_marketplace_legacy_directory}"
  build_crown_marketplace_legacy_tfplan_filename   = "${var.build_crown_marketplace_legacy_tfplan_filename}"
  build_crown_marketplace_sidekiq_directory        = "${var.build_crown_marketplace_sidekiq_directory}"
  build_crown_marketplace_sidekiq_tfplan_filename  = "${var.build_crown_marketplace_sidekiq_tfplan_filename}"
  build_crown_marketplace_tfplan_filename          = "${var.build_crown_marketplace_tfplan_filename}"
  build_crown_marketplace_upload_directory         = "${var.build_crown_marketplace_upload_directory}"
  build_crown_marketplace_upload_tfplan_filename   = "${var.build_crown_marketplace_upload_tfplan_filename}"
  build_image_ruby_directory                       = "${var.build_image_ruby_directory}"
  build_image_ruby_tfplan_filename                 = "${var.build_image_ruby_tfplan_filename}"
  build_npm1_directory                             = "${var.build_npm1_directory}"
  build_npm1_tfplan_filename                       = "${var.build_npm1_tfplan_filename}"
  build_upload_supply_teacher_data_directory       = "${var.build_upload_supply_teacher_data_directory}"
  build_upload_supply_teacher_data_tfplan_filename = "${var.build_upload_supply_teacher_data_tfplan_filename}"
  cloudwatch_logs_group_name                       = "${var.codebuild_terraform_plan_cloudwatch_logs_group_name}"
  codebuild_project_name                           = "${var.codebuild_terraform_plan_project_name}"
  codebuild_service_role                           = "${data.aws_iam_role.cmp_terraform_codebuild_role.arn}"
  environment_compute_type                         = "${var.codebuild_terraform_plan_environment_compute_type}"
  environment_image                                = "${var.codebuild_terraform_plan_environment_image}"
  environment_type                                 = "${var.codebuild_terraform_plan_environment_type}"
  infrastructure_directory                         = "${var.infrastructure_directory}"
  infrastructure_tfplan_filename                   = "${var.infrastructure_tfplan_filename}"
  security_directory                               = "${var.security_directory}"
  security_tfplan_filename                         = "${var.security_tfplan_filename}"
  source_buildspec_filepath                        = "${var.codebuild_terraform_plan_source_buildspec_filepath}"
  source_type                                      = "${var.codebuild_terraform_plan_source_type}"
  ssm_config_directory                             = "${var.ssm_config_directory}"
  ssm_config_tfplan_filename                       = "${var.ssm_config_tfplan_filename}"
}

resource "aws_codepipeline" "cmp_dev_environment_pipeline" {
  name     = "${var.codepipeline_name}"
  role_arn = "${data.aws_iam_role.cmp_terraform_codepipeline_role.arn}"

  artifact_store {
    location = "${data.aws_s3_bucket.artifact_bucket.bucket}"
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
      output_artifacts = ["${var.source_artifact}"]

      configuration = {
        Owner      = "${var.github_owner}"
        Repo       = "${var.github_repository}"
        Branch     = "${var.github_branch}"
        OAuthToken = "${data.aws_ssm_parameter.github_token.value}"
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
      input_artifacts  = ["${var.source_artifact}"]
      output_artifacts = ["${var.terraform_plan_artifact}"]
      version          = "1"

      configuration = {
        ProjectName = "${var.codebuild_terraform_plan_project_name}"
      }
    }
  }
}
