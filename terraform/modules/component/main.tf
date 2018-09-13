##############################################################
#
# Component (App / Api) module
#
##############################################################
# Type validation
# See https://github.com/hashicorp/terraform/issues/15469
##############################################################
variable "__valid_component_types__" {
  description = "Valid component types - Do Not Override"
  type = "list"
  default = ["api", "app"]
}

resource "null_resource" "is_component_type_valid" {
  count = "${contains(var.__valid_component_types__, var.type) == true ? 0 : 1}"
  "${format("Component <type> must be one of %s", join(", ", var.__valid_component_types__))}" = true
}

##############################################################
# S3 Bucket name
##############################################################

locals {
   artifact_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.build-artifacts"
}

##############################################################
# Build
##############################################################
module "build" {
  source = "../build"

  artifact_prefix = "${var.prefix}"
  artifact_name = "${var.name}"
  build_type = "${var.build_type}"
  service_role_arn = "${data.aws_iam_role.codebuild_service_role.arn}"
  vpc_id = "${data.aws_vpc.CCSDEV-Services.id}"
  subnet_ids = ["${data.aws_subnet.CCSDEV-AZ-a-Private-1.id}"]
  security_group_ids = ["${data.aws_security_group.vpc-CCSDEV-internal.id}"]
}

##############################################################
# Cloudwatch Logs
##############################################################
resource "aws_cloudwatch_log_group" "component" {
  name = "/ccs/${var.name}"
  retention_in_days = 3
}

##############################################################
# Load Balancer configuration
##############################################################
resource "aws_alb_target_group" "component" {
  name     = "CCSDEV-${var.type}-cluster-alb-${var.name}-tg"
  port     = "${var.port}"
  protocol = "${upper(var.protocol)}"
  vpc_id   = "${data.aws_vpc.CCSDEV-Services.id}"

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "${upper(var.protocol)}"
    timeout             = "5"
  }

  tags {
    "Name" = "CCSDEV_${var.type}_cluster_alb_${var.name}-tg"
  }
}

resource "aws_alb_listener_rule" "subdomain_rule" {
  listener_arn = "${data.aws_alb_listener.listener.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.component.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.name}.${var.domain}"]
  }
}

##############################################################
# DNS configuration
##############################################################
resource "aws_route53_record" "component" {
  zone_id = "${data.aws_route53_zone.base_domain.zone_id}"
  name    = "${var.name}.${var.domain}"
  type    = "A"

  alias {
    name                   = "${data.aws_alb.CCSDEV_cluster_alb.dns_name}"
    zone_id                = "${data.aws_alb.CCSDEV_cluster_alb.zone_id}"
    evaluate_target_health = true
  }
}

##############################################################
# ECS configuration
##############################################################

module "ecs_service" {
  source = "../ecs_service"

  task_name = "${var.name}"
  task_environment = "${var.environment}"
  log_group = "${aws_cloudwatch_log_group.component.name}"
  cluster_name = "${var.cluster_name}"
  image = "${module.build.image_name}"
  target_group_arn = "${aws_alb_target_group.component.arn}"
}

##############################################################
# Pipeline
##############################################################
module "pipeline" {
  source = "../pipeline"

  artifact_name = "${var.name}"
  service_role_arn = "${data.aws_iam_role.codepipeline_service_role.arn}"
  artifact_bucket_name = "${local.artifact_bucket_name}"
  github_owner = "${var.github_owner}"
  github_repo = "${var.github_repo}"
  build_project_name = "${module.build.project_name}"
  deploy_cluster_name = "${var.cluster_name}"
  deploy_service_name = "${module.ecs_service.name}"
}