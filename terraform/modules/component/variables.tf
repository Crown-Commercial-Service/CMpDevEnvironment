##############################################################
# Type of Component:
#   api - an internal service 
#   app - an external application 
##############################################################
variable type {
    type = "string"
}

variable prefix {
    type = "string"
}

variable name {
    type = "string"
}

variable build_type {
    type = "string"
}

variable build_image {
    type = "string"
}

variable github_owner {
    type = "string"
}

variable github_repo {
    type = "string"
}

variable github_branch {
    type = "string"
    default = "master"
}

variable cluster_name {
    type = "string"
}

variable environment {
    type = "list"
}

variable domain {
    type = "string"
}

variable port {
    type = "string"
}

variable protocol {
    type = "string"
}

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
  name = "codebuild-${var.type}-service-role"
}

data "aws_iam_role" "codepipeline_service_role" {
  name = "codepipeline-${var.type}-service-role"
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
    "Name" = "CCSDEV-internal-${var.type}"
  }
}

##############################################################
# Load Balancer references
##############################################################

data "aws_alb" "CCSDEV_cluster_alb" {
  name = "CCSDEV-${var.type}-cluster-alb"
}

data "aws_alb_listener" "listener" {
  load_balancer_arn = "${data.aws_alb.CCSDEV_cluster_alb.arn}"
  port = "${var.port}"
}

data "aws_route53_zone" "base_domain" {
  name         = "${var.domain}."
  private_zone = "${var.type == "api"}"
}
