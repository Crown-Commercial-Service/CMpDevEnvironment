data "aws_iam_role" "cmp_terraform_codepipeline_role" {
  name = var.iam_role_name
}

data "aws_ssm_parameter" "github_token" {
  name = var.github_token_alias
}

resource "aws_codepipeline" "cmp_dev_environment_pipeline" {
  name     = var.codepipeline_name
  role_arn = data.aws_iam_role.cmp_terraform_codepipeline_role.arn

  artifact_store {
    location = local.artifact_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      category         = "Source"
      name             = "Source"
      owner            = "ThirdParty"
      provider         = "Github"
      version          = "1"
      output_artifacts = [var.output_artifact]

      configuration = {
        Owner                = var.github_owner
        Repo                 = var.github_repository
        Branch               = var.github_branch
        PollForSourceChanges = "true"
        OAuthToken           = "${data.aws_ssm_parameter.github_token.value}"
      }
    }
  }
}
