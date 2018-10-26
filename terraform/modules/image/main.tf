##############################################################
#
# Image build
#
##############################################################
# S3 Bucket name
##############################################################

locals {
   artifact_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.build-artifacts"
}

##############################################################
# Build
##############################################################
module "build" {
  # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/build"
  source = "../build"

  artifact_prefix = "${var.prefix}"
  artifact_name = "${var.name}"
  github_owner = "${var.github_owner}"
  github_repo = "${var.github_repo}"
  github_branch = "${var.github_branch}"
  build_type = "image"
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
  build_project_name = "${module.build.build_project_name}"
}

