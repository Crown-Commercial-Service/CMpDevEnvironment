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
# Host Name (for DNS purposes)
##############################################################
variable hostname {
    type = "string"
    default = ""
}

##############################################################
# If true and additional rule will be added at the end of 
# the routing rules with a host of *
##############################################################
variable catch_all {
    type = "string"
    default = false
}

##############################################################
# Build Type (docker, java, etc.) see build module for options
##############################################################
variable build_type {
    type = "string"
}

##############################################################
# Build Image (used if build_type is set to custom)
##############################################################
variable build_image {
    type = "string"
    default = ""
}

##############################################################
# Build Image Version (if a specific version tag is required)
##############################################################
variable build_image_version {
    type = "string"
    default = "latest"
}

##############################################################
# Whether a test (5-stage) pipeline is required
##############################################################
variable enable_tests {
    type = "string"
    default = false
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
# Component source Github token alias as used in
#  the Parameter Store
##############################################################
variable github_token_alias {
    type = "string"
}

##############################################################
# ECS Cluster name
##############################################################
variable cluster_name {
    type = "string"
}


##############################################################
# Service log retention period
##############################################################
variable log_retention {
    type = "string"
    default = 3
}

##############################################################
# Desired task count
##############################################################
variable task_count {
    type = "string"
    default = 1
}

##############################################################
# Autoscaling task counts
##############################################################
variable autoscaling_min_count {
    type = "string"
    default = -1
}

variable autoscaling_max_count {
    type = "string"
    default = -1
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
    default = []
}

##############################################################
# Environment that component will be hosted within
##############################################################
variable "environment_name" {
  default = "Development"
}

##############################################################
# Port that the component will be accessible through
##############################################################
variable port {
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
# AWS Cognito support
##############################################################

variable "enable_cognito_support" {
    default = false
}

variable "cognito_login_callback" {
    type = "string"
    default = ""
}

variable "cognito_logout_callback" {
    type = "string"
    default = ""
}

variable "cognito_generate_secret" {
    default = true
}
