##############################################################
#
# Application Configuration and Support
#
# Defines:
#   Application requirements
#
##############################################################
# Build
##############################################################
module "build" {
  source = "../../modules/build"

  artifact_prefix = "${var.app_prefix}"
  artifact_name = "${var.app_name}"
  build_type = "docker"
  service_role_arn = "${data.aws_iam_role.codebuild_app_service_role.arn}"
  host_image = "aws/codebuild/docker:17.09.0"
  vpc_id = "${data.aws_vpc.CCSDEV-Services.id}"
  subnet_ids = ["${data.aws_subnet.CCSDEV-AZ-a-Private-1.id}"]
  security_group_ids = ["${data.aws_security_group.vpc-CCSDEV-internal-app.id}"]
}
