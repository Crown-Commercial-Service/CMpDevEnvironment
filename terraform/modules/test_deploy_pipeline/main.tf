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
        PollForSourceChanges = "true"
        OAuthToken = "${data.aws_ssm_parameter.github_token.value}"
      }
    }
  }

  stage {
    name = "Build_Tests"

    action {
      name             = "Test"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["${var.artifact_name}_source"]
      output_artifacts = ["${var.artifact_name}_build_test"]
      version          = "1"

      configuration {
        ProjectName = "${var.build_test_project_name}"
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
    name = "Deploy_Tests"

    action {
      name             = "Test"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["${var.artifact_name}_source"]
      output_artifacts = ["${var.artifact_name}_deploy_test"]
      version          = "1"

      configuration {
        ProjectName = "${var.deploy_test_project_name}"
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

module "pipeline_events" {
  # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/pipeline_events"
  source = "../pipeline_events"

  enable = "${var.enable}"
  name = "${var.artifact_name}-pipeline"

  github_owner = "${var.github_owner}"
  github_repo = "${var.github_repo}"
  github_branch = "${var.github_branch}"
}
