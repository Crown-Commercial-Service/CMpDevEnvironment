##############################################################
#
# Routing module
#
##############################################################

##############################################################
# "Proxy" provider; provider must be passed into the module
##############################################################
provider "aws" {
}

##############################################################
# Load Balancer configuration
##############################################################
locals {
  provision_https_certificates = "${upper(var.protocol) == "HTTPS" ? 1 : 0}"
  has_path_pattern = "${var.path_pattern == "" ? 0 : 1}"

  # it seems that even though we are not applying a path pattern
  # (via count = 0) we can't default to an empty string as the
  # condition:path_pattern doesn't like empty values, hence the "/"
  # but it could be any value as it is not used
  path_pattern = "${local.has_path_pattern ? var.path_pattern : "/"}"
  
  # only register the DNS record if this is host based routing only i.e
  # this does not have a path_pattern
  register_dns_record = "${local.has_path_pattern ? 0 : 1}"
}

resource "aws_alb_target_group" "component" {
  name                 = "CCSDEV-${var.type}-cl-alb-${var.name}-tg"
  port                 = "${var.port}"
  protocol             = "HTTP"
  vpc_id               = "${data.aws_vpc.CCSDEV-Services.id}"
  deregistration_delay = 30

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "60"
    matcher             = "200-499"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

  tags {
    "Name" = "CCSDEV_${var.type}_cl_alb_${var.name}-tg"
  }
}

resource "aws_alb_listener_rule" "http_subdomain_rule" {
  count = "${local.provision_https_certificates == 0 ? 1 : 0}"
  listener_arn = "${data.aws_alb_listener.http_listener.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.component.arn}"
  }

  condition {
    host_header {
      values = ["${var.hostname}.${var.domain}"]
    }
  }
}

resource "aws_alb_listener_rule" "http_subdomain_catchall_rule" {
  count = "${(local.provision_https_certificates == 0) && var.catch_all ? 1 : 0}"

  # catch_all comes after all other rules
  priority = 9999

  listener_arn = "${data.aws_alb_listener.http_listener.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.component.arn}"
  }

  condition {
    host_header {
      values = ["*.${var.domain}"]
    }
  }
}

resource "aws_alb_listener_rule" "http_subdomain_redirect_rule" {
  count = "${local.provision_https_certificates}"
  listener_arn = "${data.aws_alb_listener.http_listener.arn}"

  action {
    type = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["${var.hostname}.${var.domain}"]
    }
  }
}

resource "aws_alb_listener_rule" "http_subdomain_redirect_catchall_rule" {

  count = "${local.provision_https_certificates && var.catch_all ? 1 : 0}"

  # catch_all comes after all other rules
  priority = 9999

  listener_arn = "${data.aws_alb_listener.http_listener.arn}"

  action {
    type = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["*.${var.domain}"]
    }
  }
}

data "aws_alb_listener" "https_listener" {
  count = "${local.provision_https_certificates}"
  load_balancer_arn = "${data.aws_alb.CCSDEV_cluster_alb.arn}"
  port = "443"
}

resource "aws_alb_listener_rule" "https_subdomain_rule_hostname" {
  count = "${local.provision_https_certificates && !local.has_path_pattern ? 1 : 0}"
  listener_arn = "${data.aws_alb_listener.https_listener.arn}"

  # just a hostname match needs to come after the more specific hostname and path matching
  priority = 5000

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.component.arn}"
  }

  condition {
    host_header {
      values = ["${var.hostname}.${var.domain}"]
    }
  }
}

resource "aws_alb_listener_rule" "https_subdomain_rule_hostname_and_path" {
  count = "${local.provision_https_certificates && local.has_path_pattern ? 1 : 0}"
  listener_arn = "${data.aws_alb_listener.https_listener.arn}"

  # this rule comes before the other host/pathy/catch_all rules
  priority = 1000

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.component.arn}"
  }

  condition {
    host_header {
      values = ["${var.hostname}.${var.domain}"]
    }
  }

  condition {
    path_pattern {
      values = ["${local.path_pattern}"]
    }
  }

}

resource "aws_alb_listener_rule" "https_subdomain_catchall_rule" {

  count = "${local.provision_https_certificates && var.catch_all ? 1 : 0}"

  # catch_all comes after all other rules
  priority = 9999

  listener_arn = "${data.aws_alb_listener.https_listener.arn}"

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.component.arn}"
  }

  condition {
    host_header {
      values = ["*.${var.domain}"]
    }
  }
}


##############################################################
# DNS configuration
##############################################################
resource "aws_route53_record" "component" {
  count = "${local.register_dns_record}"

  zone_id = "${data.aws_route53_zone.base_domain.zone_id}"
  name    = "${var.hostname}.${var.domain}"
  type    = "A"

  alias {
    name = "${data.aws_alb.CCSDEV_cluster_alb.dns_name}"
    zone_id = "${data.aws_alb.CCSDEV_cluster_alb.zone_id}"
    evaluate_target_health = true
  }
}
