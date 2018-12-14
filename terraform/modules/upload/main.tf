##############################################################
#
# Execute build
#
##############################################################
# Various environment variables  upload_app
##############################################################

data "aws_ssm_parameter" "upload_domain_name" {
  name = "/${var.environment_name}/config/domain_name"
}

data "aws_ssm_parameter" "upload_domain_prefix" {
  name = "/${var.environment_name}/config/domain_prefix"
}

data "aws_ssm_parameter" "upload_enable_https" {
  name = "/${var.environment_name}/config/enable_https"
}

data "aws_ssm_parameter" "upload_user_name" {
  name = "/Environment/ccs/${var.upload_api}/HTTP_BASIC_AUTH_NAME"
}

data "aws_ssm_parameter" "upload_password" {
  name = "/Environment/ccs/${var.upload_api}/HTTP_BASIC_AUTH_PASSWORD"
}


locals {
   artifact_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.build-artifacts"

   upload_host = "${var.upload_api}.${data.aws_ssm_parameter.upload_domain_prefix.value}.${data.aws_ssm_parameter.upload_domain_name.value}"

   user_name = "${data.aws_ssm_parameter.upload_user_name.value}"

   password = "${data.aws_ssm_parameter.upload_password.value}"

   protocol = "${data.aws_ssm_parameter.upload_enable_https.value == "1" ? "https" : "http"}"
}

##############################################################
# Build
##############################################################
module "execute" {
  # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/execute"
  source = "../execute"

  # The command to execute:
  # ls to allow the checkout to be viewed in the logs
  # curl capturing the HTTP response code
  # if to test the response code - should be 201
  commands = "ls,STATUS=$(curl --user ${local.user_name}:${local.password} --request POST -w '%{http_code}' -o /dev/null --header 'Content-Type: application/json' --data @${var.framework}/output/${var.data_file} ${local.protocol}://${local.upload_host}/${var.framework}/uploads),echo HTTP Response: $STATUS,if [ $STATUS -ne 201 ]; then exit 99; fi"

  artifact_prefix = "${var.prefix}"
  artifact_name = "${var.name}"
  github_owner = "${var.github_owner}"
  github_repo = "${var.github_repo}"
  github_branch = "${var.github_branch}"
  build_type = "upload"
  service_role_arn = "${data.aws_iam_role.codebuild_service_role.arn}"
  vpc_id = "${data.aws_vpc.CCSDEV-Services.id}"
  subnet_ids = ["${data.aws_subnet.CCSDEV-AZ-a-Private-1.id}"]
  security_group_ids = ["${data.aws_security_group.vpc-CCSDEV-internal.id}"]
}

##############################################################
# Pipeline
##############################################################
module "pipeline" {
  # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/build_pipeline"
  source = "../build_pipeline"

  artifact_name = "${var.name}"
  service_role_arn = "${data.aws_iam_role.codepipeline_service_role.arn}"
  artifact_bucket_name = "${local.artifact_bucket_name}"
  github_owner = "${var.github_owner}"
  github_repo = "${var.github_repo}"
  github_branch = "${var.github_branch}"
  github_token_alias = "${var.github_token_alias}"
  build_project_name = "${module.execute.build_project_name}"
}

