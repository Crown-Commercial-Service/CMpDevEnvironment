##############################################################
#
# Application Configuration and Support
#
# Defines:
#   Application requirements
#
##############################################################
# Cloudwatch Logs
##############################################################
resource "aws_cloudwatch_log_group" "app" {
  name = "/ccs/${var.app_name}"
  retention_in_days = 3
}

##############################################################
# Load Balancer configuration
##############################################################
resource "aws_alb_target_group" "CCSDEV_app_cluster_alb_app_tg" {
  name     = "CCSDEV-app-cluster-alb-${var.app_name}-tg"
  port     = "${var.app_port}"
  protocol = "${upper(var.app_protocol)}"
  vpc_id   = "${data.aws_vpc.CCSDEV-Services.id}"

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "${upper(var.app_protocol)}"
    timeout             = "5"
  }

  tags {
    "Name" = "CCSDEV_app_cluster_alb_${var.app_name}-tg"
  }
}

resource "aws_alb_listener_rule" "subdomain_rule" {
  listener_arn = "${data.aws_alb_listener.app_listener.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.CCSDEV_app_cluster_alb_app_tg.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.app_name}.${var.domain}"]
  }
}

##############################################################
# DNS configuration
##############################################################
resource "aws_route53_record" "app" {
  zone_id = "${data.aws_route53_zone.base_domain.zone_id}"
  name    = "${var.app_name}.${var.domain}"
  type    = "A"

  alias {
    name                   = "${data.aws_alb.CCSDEV_app_cluster_alb.dns_name}"
    zone_id                = "${data.aws_alb.CCSDEV_app_cluster_alb.zone_id}"
    evaluate_target_health = true
  }
}

##############################################################
# ECS configuration
##############################################################
locals {
    environment = [
      {
        name = "CCS_APP_BASE_URL",
        value = "${var.domain}"
      },
      {
        name = "CCS_APP_PROTOCOL",
        value = "${var.app_protocol}"
      }, 
      {
        name = "CCS_FEATURE_EG1",
        value = "off"
      } 
    ]
}

module "ecs_service" {
  source = "../../modules/ecs_service"

  task_name = "${var.app_name}"
  task_environment = "${local.environment}"
  log_group = "${aws_cloudwatch_log_group.app.name}"
  cluster_name = "CCSDEV_app_cluster"
  image = "${aws_ecr_repository.app.repository_url}:latest"
  target_group_arn = "${aws_alb_target_group.CCSDEV_app_cluster_alb_app_tg.arn}"
}

##############################################################
# Pipeline
##############################################################
module "pipeline" {
  source = "../../modules/pipeline"

  artifact_name = "${var.app_name}"
  service_role_arn = "${data.aws_iam_role.codepipeline_app_service_role.arn}"
  artifact_bucket_name = "${local.artifact_bucket_name}"
  github_owner = "${var.github_owner}"
  github_repo = "${var.github_repo}"
  build_project_name = "${module.build.project_name}"
  deploy_cluster_name = "CCSDEV_app_cluster"
  deploy_service_name = "${module.ecs_service.name}"
}
