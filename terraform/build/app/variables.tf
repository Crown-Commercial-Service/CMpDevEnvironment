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

data "aws_security_group" "vpc-CCSDEV-internal-app" {
  tags {
    "Name" = "CCSDEV-internal-app"
  }
}

data "aws_alb" "CCSDEV_app_cluster_alb" {
  name = "CCSDEV-app-cluster-alb"
}

data "aws_alb_listener" "http_listener" {
  load_balancer_arn = "${data.aws_alb.CCSDEV_app_cluster_alb.arn}"
  port = "${var.http_port}"
}

data "aws_route53_zone" "base_domain" {
  name         = "${var.domain}."
  private_zone = false
}

variable "domain" {
    default = "roweitdev.co.uk"
}

variable "http_port" {
  default = 80
}

variable "app_prefix" {
  default = "ccs"
}

variable "app_name" {
  default = "app1"
}