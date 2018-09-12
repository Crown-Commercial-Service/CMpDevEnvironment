##############################################################
#
# CodeBuild module
#
##############################################################

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
    image           = "${var.host_image}"
    type            = "${var.host_type}"
    privileged_mode = "${var.host_is_privileged}"
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "${var.spec}"
  }

  vpc_config {
    vpc_id = "${var.vpc_id}"

    subnets = ["${var.subnet_ids}"]

    security_group_ids = ["${var.security_group_ids}"]
  }
}