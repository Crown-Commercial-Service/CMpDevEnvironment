##############################################################
#
# CCSDEV Application Cluster
#
# Defines:
#   ECS Cluster for application containers
#
##############################################################

resource "aws_ecs_cluster" "CCSDEV_app_cluster" {
  name = "CCSDEV_app_cluster"
}

##############################################################
# Load balancer for container access
##############################################################

resource "aws_alb" "CCSDEV_app_cluster_alb" {
  name            = "CCSDEV-app-cluster-alb"
  internal        = false
  security_groups = ["${aws_security_group.vpc-CCSDEV-external-app-alb.id}"]
  subnets         = ["${aws_subnet.CCSDEV-AZ-a-Public-1.id}", "${aws_subnet.CCSDEV-AZ-b-Public-1.id}", "${aws_subnet.CCSDEV-AZ-c-Public-1.id}"]

  access_logs {
    bucket  = "${local.log_bucket_name}"
    prefix  = "alb/app"
    enabled = "${var.app_cluster_alb_logging_enabled}"
  }

  tags {
    Name = "CCSDEV_app_cluster_alb"
    CCSRole = "Application"
    CCSEnvironment = "${var.environment_name}"
  }
}

##############################################################
# Load balancer external HTTP entry point
##############################################################

resource "aws_alb_listener" "CCSDEV_app_cluster_alb_listener_http" {
  load_balancer_arn = "${aws_alb.CCSDEV_app_cluster_alb.arn}"
  port              = "${var.http_port}"
  protocol          = "HTTP"

  default_action {

    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code = "404"
    }
  }
}

##############################################################
# Load balancer external HTTPS entry point
##############################################################
resource "aws_acm_certificate" "public_cluster_wildcard_certificate" {
  count             = "${var.enable_https}"
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "public_cluster_wildcard_certificate_validation_dns" {
  count   = "${var.enable_https}"
  name    = "${aws_acm_certificate.public_cluster_wildcard_certificate.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.public_cluster_wildcard_certificate.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.public_cluster_https_domain.id}"
  records = ["${aws_acm_certificate.public_cluster_wildcard_certificate.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "public_cluster_wildcard_certificate_validation" {
  count                   = "${var.enable_https}"
  certificate_arn         = "${aws_acm_certificate.public_cluster_wildcard_certificate.arn}"
  validation_record_fqdns = [
    "${aws_route53_record.public_cluster_wildcard_certificate_validation_dns.fqdn}"
    ]
}

resource "aws_alb_listener" "CCSDEV_app_cluster_alb_listener_https" {
  count             = "${var.enable_https}"
  load_balancer_arn = "${aws_alb.CCSDEV_app_cluster_alb.arn}"
  port              = "${var.https_port}"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-2019-08"
  certificate_arn   = "${aws_acm_certificate.public_cluster_wildcard_certificate.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.CCSDEV_app_cluster_alb_def_tg.arn}"
  }
}

##############################################################
# Default target group
# Requests will be routed to this when no app path is specifed
# As app containers are created a corresponding target
# group and routing rule will be added.
##############################################################

resource "aws_alb_target_group" "CCSDEV_app_cluster_alb_def_tg" {
  name     = "CCSDEV-app-cl-alb-def-tg"
  port     = "${var.http_port}"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.CCSDEV-Services.id}"

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

  tags {
    Name = "CCSDEV_app_cl_alb_def-tg"
    CCSRole = "Application"
    CCSEnvironment = "${var.environment_name}"
  }
}

##############################################################
# Autoscaling group for the Api cluster
##############################################################

resource "aws_autoscaling_group" "CCSDEV_app_cluster_scaling" {
  name                 = "CCSDEV_app_cluster_scaling"
  max_size             = "${var.app_cluster_max_instance_count}"
  min_size             = "${var.app_cluster_min_instance_count}"
  desired_capacity     = "${var.app_cluster_desired_instance_count}"
  vpc_zone_identifier  = ["${aws_subnet.CCSDEV-AZ-a-Public-1.id}", "${aws_subnet.CCSDEV-AZ-b-Public-1.id}", "${aws_subnet.CCSDEV-AZ-c-Public-1.id}"]
  launch_configuration = "${aws_launch_configuration.CCSDEV_app_cluster_launch_config.name}"
  health_check_type    = "ELB"

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = "CCSDEV_app_cluster_host"
      propagate_at_launch = true
    },
    {
      key                 = "CCSRole"
      value               = "Application"
      propagate_at_launch = true
    },
    {
      key                 = "CCSEnvironment"
      value               = "${var.environment_name}"
      propagate_at_launch = true
    },
  ]
}

##############################################################
# Launch configuration information 
##############################################################

resource "aws_launch_configuration" "CCSDEV_app_cluster_launch_config" {
  name_prefix                 = "CCSDEV_app_cluster_launch_config_"
  image_id                    = "${var.app_cluster_ami}"
  instance_type               = "${var.app_cluster_instance_class}"
  iam_instance_profile        = "${aws_iam_instance_profile.CCSDEV_app_cluster_instance_profile.arn}"
  security_groups             = ["${aws_security_group.vpc-CCSDEV-internal-app.id}", "${aws_security_group.vpc-CCSDEV-external-app.id}", "${aws_security_group.vpc-CCSDEV-internal-ssh.id}"]
  associate_public_ip_address = "true"
  key_name                    = "${var.app_cluster_key_name}"
  user_data                   = "${data.template_file.CCSDEV_app_cluster_user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

}

data "template_file" "CCSDEV_app_cluster_user_data" {
  template = "${file("./app_userdata.tpl")}"

  vars {
    ecs-cluster-name = "${aws_ecs_cluster.CCSDEV_app_cluster.name}"
  }
}

##############################################################
# IAM Roles and Polices for App Cluster
##############################################################

resource "aws_iam_instance_profile" "CCSDEV_app_cluster_instance_profile" {
  name = "CCSDEV-app-cluster-instance-profile"
  path = "/"
  role = "${aws_iam_role.CCSDEV_app_cluster_instance_role.name}"
}

resource "aws_iam_role" "CCSDEV_app_cluster_instance_role" {
  name               = "CCSDEV-app-cluster-instance-role"
  description        = "Role for ECS instances in the CCSDEV App Cluster"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.CCSDEV_app_cluster_instance_policy.json}"
}

data "aws_iam_policy_document" "CCSDEV_app_cluster_instance_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "CCSDEV_app_cluster_instance_role_attachment" {
  role       = "${aws_iam_role.CCSDEV_app_cluster_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
