##############################################################
# Type of Component:
#   api - an internal service 
#   app - an external application 
##############################################################
variable type {
    type = "string"
}

##############################################################
# Component Prefix  
##############################################################
variable prefix {
    type = "string"
    default = "ccs"
}

##############################################################
# Component Name
##############################################################
variable name {
    type = "string"
}

##############################################################
# Build Type (docker, java, etc.) see build module for options
##############################################################
variable build_type {
    type = "string"
}

##############################################################
# Component source Github user/org
##############################################################
variable github_owner {
    type = "string"
}

##############################################################
# Component source Github repo
##############################################################
variable github_repo {
    type = "string"
}

##############################################################
# Component source Github branch
##############################################################
variable github_branch {
    type = "string"
    default = "master"
}

##############################################################
# ECS Cluster name
##############################################################
variable cluster_name {
    type = "string"
}

##############################################################
# Any environment variables to run within the container
#  when deployed within ECS, e.g.
#
# [
#   { name = "ENV_VAR_1", value = "123"},
#   { name = "ENV_VAR_2", value = "abc"} 
# ]
##############################################################
variable environment {
    type = "list"
}

##############################################################
# Domain that component will be hosted within,e.g. example.com
##############################################################
variable domain {
    type = "string"
}

##############################################################
# Port that the component will be accessible through
##############################################################
variable port {
    type = "string"
}

##############################################################
# Protocol that the component will be accessible through
##############################################################
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
