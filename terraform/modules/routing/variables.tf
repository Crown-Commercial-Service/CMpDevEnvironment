##############################################################
# Type of Component:
#   api - an internal service 
#   app - an external application 
##############################################################
variable type {
    type = "string"
}

##############################################################
# Component Name
##############################################################
variable name {
    type = "string"
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

##############################################################
# Infrastructure references
##############################################################

data "aws_vpc" "CCSDEV-Services" {
  tags {
    "Name" = "CCSDEV Services"
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
