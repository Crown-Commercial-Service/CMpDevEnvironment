##############################################################
#
# Application Configuration and Support
#
# Defines:
#   Application requirements
#
##############################################################
# Container Repository
##############################################################
resource "aws_ecr_repository" "app" {
  name = "${var.app_prefix}/${var.app_name}"
}

##############################################################
# Codebuild Project
##############################################################
data "template_file" "buildspec" {
  template = "${file("${"${path.module}/docker_buildspec.yml"}")}"

  vars {
    container_prefix = "${var.app_prefix}"
    container_name = "${var.app_name}"
    image_name = "${aws_ecr_repository.app.repository_url}:latest"
  }
}

resource "aws_codebuild_project" "app" {
  name          = "${var.app_name}-build-project"
  description   = "${var.app_name}_codebuild_project"
  build_timeout = "60" # Default 60 minutes
  service_role  = "${data.aws_iam_role.codebuild_app_service_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:17.09.0"
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
      "${data.aws_security_group.vpc-CCSDEV-internal-app.id}",
    ]
  }
}