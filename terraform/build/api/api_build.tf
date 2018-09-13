##############################################################
#
# API Configuration and Support
#
# Defines:
#   API requirements
#
##############################################################
# Build
##############################################################
module "build" {
  source = "../../modules/build"

  artifact_prefix = "${var.api_prefix}"
  artifact_name = "${var.api_name}"
  build_type = "java"
  service_role_arn = "${data.aws_iam_role.codebuild_api_service_role.arn}"
  host_image = "aws/codebuild/java:openjdk-8"
  vpc_id = "${data.aws_vpc.CCSDEV-Services.id}"
  subnet_ids = ["${data.aws_subnet.CCSDEV-AZ-a-Private-1.id}"]
  security_group_ids = ["${data.aws_security_group.vpc-CCSDEV-internal-api.id}"]
}
