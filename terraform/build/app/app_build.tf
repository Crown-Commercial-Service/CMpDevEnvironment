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

module "build" {
  source = "../../modules/build"

  artifact_prefix = "${var.app_prefix}"
  artifact_name = "${var.app_name}"
  spec = "${data.template_file.buildspec.rendered}"
  service_role_arn = "${data.aws_iam_role.codebuild_app_service_role.arn}"
  host_image = "aws/codebuild/docker:17.09.0"
  vpc_id = "${data.aws_vpc.CCSDEV-Services.id}"
  subnet_ids = ["${data.aws_subnet.CCSDEV-AZ-a-Private-1.id}"]
  security_group_ids = ["${data.aws_security_group.vpc-CCSDEV-internal-app.id}"]
}
