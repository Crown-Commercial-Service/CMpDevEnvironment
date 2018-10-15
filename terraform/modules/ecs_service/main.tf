##############################################################
#
# ECS Service module
#
##############################################################
data "aws_ecs_cluster" "cluster" {
  cluster_name = "${var.cluster_name}"
}

data "template_file" "task_definition" {
  template = "${file("${"${path.module}/task_definition.tpl"}")}"

  vars {
    name = "${var.task_name}"
    image = "${var.image}"
    environment = "${jsonencode(var.task_environment)}"
    log_group = "${var.log_group}"
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "${var.task_name}"
  container_definitions = "${data.template_file.task_definition.rendered}"
}

resource "aws_ecs_service" "service" {
  name            = "${var.task_name}"
  cluster         = "${data.aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.task_definition.arn}"
  desired_count   = "${var.task_count}"
  deployment_maximum_percent = "${(50 * var.task_count) + 150}"
  deployment_minimum_healthy_percent = "${100 / var.task_count}"
  health_check_grace_period_seconds = 120

  load_balancer {
    target_group_arn = "${var.target_group_arn}"
    container_name   = "${var.task_name}"
    container_port   = 8080
  }
}

locals {
  enable_autoscaling = "${(var.autoscaling_max_count > 1 || var.autoscaling_min_count >= 0) ? 1 : 0}"
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  count               = "${local.enable_autoscaling}"
  alarm_name          = "${var.task_name}-service-CPU-Utilization-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"

  dimensions {
    ClusterName = "${data.aws_ecs_cluster.cluster.cluster_name}"
    ServiceName = "${aws_ecs_service.service.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.service_up.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  count               = "${local.enable_autoscaling}"
  alarm_name          = "${var.task_name}-service-CPU-Utilization-Low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"

  dimensions {
    ClusterName = "${data.aws_ecs_cluster.cluster.cluster_name}"
    ServiceName = "${aws_ecs_service.service.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.service_down.arn}"]
}

resource "aws_appautoscaling_target" "ecs_target" {
  count              = "${local.enable_autoscaling}"
  max_capacity       = "${var.autoscaling_max_count > 1 ? var.autoscaling_max_count : var.task_count}"
  min_capacity       = "${var.autoscaling_min_count >= 0 ? var.autoscaling_min_count : var.task_count}"
  resource_id        = "service/${data.aws_ecs_cluster.cluster.cluster_name}/${aws_ecs_service.service.name}"
  role_arn           = "${var.ecs_service_arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Helpful reference: https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-simple-step.html

resource "aws_appautoscaling_policy" "service_up" {
  count                     = "${local.enable_autoscaling}"
  name                      = "${var.task_name}-scale-up"
  service_namespace         = "ecs"
  resource_id               = "service/${data.aws_ecs_cluster.cluster.cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension        = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment = 1
    }
  }

  depends_on = [
    "aws_appautoscaling_target.ecs_target"
  ]
}

resource "aws_appautoscaling_policy" "service_down" {
  count                     = "${local.enable_autoscaling}"
  name                      = "${var.task_name}-scale-down"
  service_namespace         = "ecs"
  resource_id               = "service/${data.aws_ecs_cluster.cluster.cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension        = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type           = "ChangeInCapacity"
    cooldown                  = 120
    metric_aggregation_type   = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment = -1
    }
  }

  depends_on = [
    "aws_appautoscaling_target.ecs_target"
  ]
}
