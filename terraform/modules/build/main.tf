##############################################################
#
# CodeBuild module
#
##############################################################
locals {
  base_image_name = "${aws_ecr_repository.build.repository_url}"
  deploy_image_name = "${local.base_image_name}:latest"

  build_images = {
    docker = "aws/codebuild/docker:17.09.0"
    java = "aws/codebuild/java:openjdk-8"
    npm-publish = "aws/codebuild/nodejs:8.11.0"
    python = "aws/codebuild/python:3.6.5"
  }
  __valid_build_types__ = "${keys(local.build_images)}"
}

resource "null_resource" "is_build_type_valid" {
  count = "${contains(local.__valid_build_types__, var.build_type) == true ? 0 : 1}"
  "${format("Build <type> must be one of %s", join(", ", local.__valid_build_types__))}" = true
}

data "template_file" "buildspec" {
  template = "${file("${"${path.module}/${var.build_type}_buildspec.yml"}")}"

  vars {
    github_owner = "${var.github_owner}"
    github_repo = "${var.github_repo}"
    github_branch = "${var.github_branch}"
    container_prefix = "${var.artifact_prefix}"
    container_name = "${var.artifact_name}"
    base_image_name = "${local.base_image_name}"
    deploy_image_name = "${local.deploy_image_name}"
  }
}

resource "aws_ecr_repository" "build" {
  name = "${var.artifact_prefix}/${var.artifact_name}"
}

resource "aws_codebuild_project" "project" {
  name          = "${var.artifact_name}-build-project"
  description   = "${var.artifact_name}_codebuild_project"
  build_timeout = "${var.timeout}"
  service_role  = "${var.service_role_arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "${var.host_compute_type}"
    image           = "${lookup(local.build_images, var.build_type)}"
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
}