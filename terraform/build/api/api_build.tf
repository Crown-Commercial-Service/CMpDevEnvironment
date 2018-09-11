##############################################################
#
# API Configuration and Support
#
# Defines:
#   API requirements
#
##############################################################
# Container Repository
##############################################################
resource "aws_ecr_repository" "api" {
  name = "${var.api_prefix}/${var.api_name}"
}

##############################################################
# Codebuild Project
##############################################################
data "template_file" "buildspec" {
  template = "${file("${"${path.module}/docker_buildspec.yml"}")}"

  vars {
    container_prefix = "${var.api_prefix}"
    container_name = "${var.api_name}"
    image_name = "${aws_ecr_repository.api.repository_url}:latest"
  }
}

resource "aws_codebuild_project" "api" {
  name          = "${var.api_name}-build-project"
  description   = "${var.api_name}_codebuild_project"
  build_timeout = "60" # Default 60 minutes
  service_role  = "${data.aws_iam_role.codebuild_api_service_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/java:openjdk-8"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "${data.template_file.buildspec.rendered}"
  }

  vpc_config {
    vpc_id = "${data.aws_vpc.CCSDEV-Services.id}"

    subnets = [
      "${data.aws_subnet.CCSDEV-AZ-a-Private-1.id}",
    ]

    security_group_ids = [
      "${data.aws_security_group.vpc-CCSDEV-internal-api.id}",
    ]
  }
}