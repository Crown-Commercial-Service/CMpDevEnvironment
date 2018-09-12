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

data "aws_iam_role" "codebuild_app_service_role" {
  name = "codebuild-app-service-role"
}

data "aws_iam_role" "codepipeline_app_service_role" {
  name = "codepipeline-app-service-role"
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

data "aws_security_group" "vpc-CCSDEV-internal-app" {
  tags {
    "Name" = "CCSDEV-internal-app"
  }
}

##############################################################
# Load Balancer references
##############################################################

data "aws_alb" "CCSDEV_app_cluster_alb" {
  name = "CCSDEV-app-cluster-alb"
}

data "aws_alb_listener" "app_listener" {
  load_balancer_arn = "${data.aws_alb.CCSDEV_app_cluster_alb.arn}"
  port = "${var.app_port}"
}

data "aws_route53_zone" "base_domain" {
  name         = "${var.domain}."
  private_zone = false
}

##############################################################
# App Definitions
##############################################################

variable "domain" {
    default = "roweitdev.co.uk"
}

variable "app_protocol" {
  default = "http"
}

variable "app_port" {
  default = 80
}

variable "app_prefix" {
  default = "ccs"
}

variable "app_name" {
  default = "app1"
}

##############################################################
# Github References
##############################################################

variable github_owner {
  default = "RoweIT"
}

variable github_repo {
  default = "CCSExampleApp1"
}

variable github_branch {
  default = "master"
}

##############################################################
# S3 Bucket name
##############################################################

locals {
   artifact_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.build-artifacts"
}
