##############################################################
#
# CCSDEV API Cluster
#
# Defines:
#   ECS Cluster for API containers
#
##############################################################

resource "aws_ecs_cluster" "CCSDEV_api_cluster" {
  name = "CCSDEV_api_cluster"
}

##############################################################
# Load balancer for container access
##############################################################

resource "aws_alb" "CCSDEV_api_cluster_alb" {
  name            = "CCSDEV-api-cluster-alb"
  internal        = true
  security_groups = ["${aws_security_group.vpc-CCSDEV-internal-api-alb.id}"]
  subnets         = ["${aws_subnet.CCSDEV-AZ-a-Private-1.id}", "${aws_subnet.CCSDEV-AZ-b-Private-1.id}", "${aws_subnet.CCSDEV-AZ-c-Private-1.id}"]

  tags {
    "Name" = "CCSDEV_api_cluster_alb"
  }
}

##############################################################
# Load balancer external HTTP entry point
##############################################################

resource "aws_alb_listener" "CCSDEV_api_cluster_alb_listener_http" {
  load_balancer_arn = "${aws_alb.CCSDEV_api_cluster_alb.arn}"
  port              = "${var.http_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.CCSDEV_api_cluster_alb_def_tg.arn}"
    type             = "forward"
  }
}

##############################################################
# Load balancer external HTTPS entry point
##############################################################
# TODO Will need to define a https listener

##############################################################
# Default target group
# Requests will be routed to this when no api path is specifed
# As api containers are created a corresponding target
# group and routing rule will be added.
##############################################################

resource "aws_alb_target_group" "CCSDEV_api_cluster_alb_def_tg" {
  name     = "CCSDEV-api-cluster-alb-def-tg"
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
    "Name" = "CCSDEV_api_cluster_alb_def-tg"
  }
}

##############################################################
# Autoscaling group for the Api cluster
##############################################################

resource "aws_autoscaling_group" "CCSDEV_api_cluster_scaling" {
  name                 = "CCSDEV_api_cluster_scaling"
  max_size             = "${var.api_cluster_instance_count}"
  min_size             = "${var.api_cluster_instance_count}"
  desired_capacity     = "${var.api_cluster_instance_count}"
  vpc_zone_identifier  = ["${aws_subnet.CCSDEV-AZ-a-Private-1.id}","${aws_subnet.CCSDEV-AZ-b-Private-1.id}","${aws_subnet.CCSDEV-AZ-c-Private-1.id}"]
  launch_configuration = "${aws_launch_configuration.CCSDEV_api_cluster_launch_config.name}"
  health_check_type    = "ELB"

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = "CCSDEV_api_cluster_host"
      propagate_at_launch = true
    },
  ]
}

##############################################################
# Launch configuration information 
##############################################################

resource "aws_launch_configuration" "CCSDEV_api_cluster_launch_config" {
  name_prefix                 = "CCSDEV_api_cluster_launch_config_"
  image_id                    = "${var.api_cluster_ami}"
  instance_type               = "${var.api_cluster_instance_class}"
  iam_instance_profile        = "${aws_iam_instance_profile.CCSDEV_api_cluster_instance_profile.arn}"
  security_groups             = ["${aws_security_group.vpc-CCSDEV-internal-api.id}", "${aws_security_group.vpc-CCSDEV-internal-ssh.id}"]
  associate_public_ip_address = "false"
  key_name                    = "${var.api_cluster_key_name}"
  user_data                   = "${data.template_file.CCSDEV_api_cluster_user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

}

data "template_file" "CCSDEV_api_cluster_user_data" {
  template = "${file("./api_userdata.tpl")}"

  vars {
    ecs-cluster-name = "${aws_ecs_cluster.CCSDEV_api_cluster.name}"
  }
}

##############################################################
# IAM Roles and Polices for Api Cluster
##############################################################

resource "aws_iam_instance_profile" "CCSDEV_api_cluster_instance_profile" {
    name = "CCSDEV-api-cluster-instance-profile"
    path = "/"
    role = "${aws_iam_role.CCSDEV_api_cluster_instance_role.name}"
}

resource "aws_iam_role" "CCSDEV_api_cluster_instance_role" {
    name                = "CCSDEV-api-cluster-instance-role"
    description         = "Role for ECS instances in the CCSDEV Api Cluster"
    path                = "/"
    assume_role_policy  = "${data.aws_iam_policy_document.CCSDEV_api_cluster_instance_policy.json}"
}

data "aws_iam_policy_document" "CCSDEV_api_cluster_instance_policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "CCSDEV_api_cluster_instance_role_attachment" {
    role       = "${aws_iam_role.CCSDEV_api_cluster_instance_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
