##############################################################
#
# CodePipeline module
#
##############################################################
data "aws_ssm_parameter" "github_token" {
  count = "${var.enable ? 1 : 0}"
  name  = "${var.github_token_alias}"
}

resource "aws_codepipeline" "pipeline" {
  count = "${var.enable}"
  name     = "${var.artifact_name}-pipeline"
  role_arn = "${var.service_role_arn}"

  artifact_store {
    location = "${var.artifact_bucket_name}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["${var.artifact_name}_source"]

      configuration {
        Owner      = "${var.github_owner}"
        Repo       = "${var.github_repo}"
        Branch     = "${var.github_branch}"
        PollForSourceChanges = "false"
        OAuthToken = "${data.aws_ssm_parameter.github_token.value}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["${var.artifact_name}_source"]
      output_artifacts = ["${var.artifact_name}_build"]
      version          = "1"

      configuration {
        ProjectName = "${var.build_project_name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["${var.artifact_name}_build"]
      version         = "1"

      configuration {
        ClusterName = "${var.deploy_cluster_name}"
        ServiceName = "${var.deploy_service_name}"
        FileName    = "${var.deploy_json_filename}"
      }
    }
  }
}