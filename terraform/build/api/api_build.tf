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
# Build
##############################################################

data "template_file" "buildspec" {
  template = "${file("${"${path.module}/docker_buildspec.yml"}")}"

  vars {
    container_prefix = "${var.api_prefix}"
    container_name = "${var.api_name}"
    image_name = "${aws_ecr_repository.api.repository_url}:latest"
  }
}

module "build" {
  source = "../../modules/build"

  artifact_prefix = "${var.api_prefix}"
  artifact_name = "${var.api_name}"
  spec = "${data.template_file.buildspec.rendered}"
  service_role_arn = "${data.aws_iam_role.codebuild_api_service_role.arn}"
  host_image = "aws/codebuild/java:openjdk-8"
  vpc_id = "${data.aws_vpc.CCSDEV-Services.id}"
  subnet_ids = ["${data.aws_subnet.CCSDEV-AZ-a-Private-1.id}"]
  security_group_ids = ["${data.aws_security_group.vpc-CCSDEV-internal-api.id}"]
}
