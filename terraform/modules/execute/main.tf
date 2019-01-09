##############################################################
#
# CodeBuild module
#
##############################################################
locals {
#  base_image_name = "${aws_ecr_repository.build.repository_url}"
# deploy_image_name = "${local.base_image_name}:latest"
#  test_spec_prefix = "${var.build_type == "custom" ? "customtest" : "test"}"

  build_images = {
    upload = "aws/codebuild/docker:17.09.0"
  }
  build_image = "${lookup(local.build_images, var.build_type)}"

  __valid_build_types__ = "${keys(local.build_images)}"
}

resource "null_resource" "is_build_type_valid" {
  count = "${contains(local.__valid_build_types__, var.build_type) == true ? 0 : 1}"
  "${format("Build <type> must be one of %s", join(", ", local.__valid_build_types__))}" = true
}

data "template_file" "buildspec" {
  template = "${file("${path.module}/${var.build_type}_buildspec.yml")}"

  vars {
    github_owner = "${var.github_owner}"
    github_repo = "${var.github_repo}"
    github_branch = "${var.github_branch}"
    container_prefix = "${var.artifact_prefix}"
    container_name = "${var.artifact_name}"

    commands = "${var.commands}"
  }
}

resource "aws_codebuild_project" "build_project" {
  name          = "${var.artifact_name}-build-project"
  description   = "${var.artifact_name}_codebuild_project"
  build_timeout = "${var.timeout}"
  service_role  = "${var.service_role_arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "${var.host_compute_type}"
    image           = "${local.build_image}"
    type            = "${var.host_type}"
    privileged_mode = "${var.host_is_privileged}"
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "${data.template_file.buildspec.rendered}"
  }

  vpc_config {
    vpc_id = "${var.vpc_id}"

    subnets = ["${var.subnet_ids}"]

    security_group_ids = ["${var.security_group_ids}"]
  }

  tags {
    CCSRole = "Build"
    CCSEnvironment = "${var.environment_name}"
  }
}

