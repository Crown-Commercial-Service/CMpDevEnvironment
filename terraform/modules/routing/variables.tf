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
# Hostname that the component is at,e.g. app1 (.example.com)
##############################################################
variable hostname {
    type = "string"
}

##############################################################
# Path pattern to use for routing
##############################################################
variable path_patterns {
    type = "list"
    default = []
}

##############################################################
# Flag to register the DNS record, assumes it always does and
# can then be disabled if another build process is hanlding
# the registration
##############################################################
variable register_dns_record {
  type = "string"
  default = true
}

##############################################################
# Used to set the offset for routing rule numbers
##############################################################
variable routing_priority_offset {
    type = "string"
    default = "0"
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
# Path to use for health check
##############################################################
variable health_check_path {
    type = "string"
    default = "/"
}

##############################################################
# Port that the component will be accessible through
##############################################################
variable port {
    type = "string"
}

##############################################################
# Protocol that the component will be accessible through
# NOTE: This it the protocol between an external source and
#       the load balancer. The load balancer will still use
#       HTTP directly to the component.
##############################################################
variable protocol {
    type = "string"
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

data "aws_alb_listener" "http_listener" {
  load_balancer_arn = "${data.aws_alb.CCSDEV_cluster_alb.arn}"
  port = "${var.port}"
}

data "aws_route53_zone" "base_domain" {
  name         = "${var.domain}."
  private_zone = "${var.type == "api"}"
}
