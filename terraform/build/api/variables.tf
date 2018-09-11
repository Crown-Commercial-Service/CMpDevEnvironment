##############################################################
# VPC References
##############################################################
provider "aws" {
  region     = "eu-west-2"
}

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

data "aws_security_group" "vpc-CCSDEV-internal-api" {
  tags {
    "Name" = "CCSDEV-internal-api"
  }
}

data "aws_alb" "CCSDEV_api_cluster_alb" {
  name = "CCSDEV-api-cluster-alb"
}

data "aws_alb_listener" "api_listener" {
  load_balancer_arn = "${data.aws_alb.CCSDEV_api_cluster_alb.arn}"
  port = "${var.api_port}"
}

data "aws_route53_zone" "base_domain" {
  name         = "${var.domain}."
  private_zone = true
}

variable "domain" {
    default = "ccsdev-internal.org"
}

variable "api_protocol" {
  default = "http"
}
variable "api_port" {
  default = 80
}

variable "api_prefix" {
  default = "ccs"
}

variable "api_name" {
  default = "api1"
}


variable github_owner {
  default = "RoweIT"
}

variable github_repo {
  default = "CCSExampleApi1"
}

variable github_branch {
  default = "master"
}