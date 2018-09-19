##############################################################
#
# NPM publish
#
##############################################################
# AWS Provider
##############################################################
provider "aws" {
  region = "eu-west-2"
}

data "aws_caller_identity" "current" {
}

##############################################################
# IAM references
##############################################################

data "aws_iam_role" "codebuild_service_role" {
  name = "codebuild-api-service-role"
}

data "aws_iam_role" "codepipeline_service_role" {
  name = "codepipeline-api-service-role"
}

##############################################################
# Infrastructure references
##############################################################

data "aws_vpc" "CCSDEV-Services" {
  tags {
    "Name" = "CCSDEV Services"
  }
}

data "aws_subnet" "CCSDEV-AZ-a-Private-1" {
  tags {
    "Name" = "CCSDEV-AZ-a-Private-1"
  }
}

data "aws_security_group" "vpc-CCSDEV-internal" {
  tags {
    "Name" = "CCSDEV-internal-api"
  }
}

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
  source = "../../modules/build"

  artifact_prefix = "ccs"
  artifact_name = "npm1"
  github_owner = "RoweIT"
  github_repo = "CCSExampleNPMModule"
  build_type = "npm-publish"
  service_role_arn = "${data.aws_iam_role.codebuild_service_role.arn}"
  vpc_id = "${data.aws_vpc.CCSDEV-Services.id}"
  subnet_ids = ["${data.aws_subnet.CCSDEV-AZ-a-Private-1.id}"]
  security_group_ids = ["${data.aws_security_group.vpc-CCSDEV-internal.id}"]
}

##############################################################
# Pipeline
##############################################################
module "pipeline" {
  source = "../../modules/build_pipeline"

  artifact_name = "npm1"
  service_role_arn = "${data.aws_iam_role.codepipeline_service_role.arn}"
  artifact_bucket_name = "${local.artifact_bucket_name}"
  github_owner = "RoweIT"
  github_repo = "CCSExampleNPMModule"
  build_project_name = "${module.build.project_name}"
}

