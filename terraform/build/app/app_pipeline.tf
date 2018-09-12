##############################################################
#
# Application Configuration and Support
#
# Defines:
#   Application requirements
#
##############################################################
# Build Artifact Storage
##############################################################
data "aws_s3_bucket" "build-artifacts" {
  bucket = "${local.artifact_bucket_name}"
}

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
data "aws_ecs_cluster" "app_cluster" {
  cluster_name = "CCSDEV_app_cluster"
}

data "template_file" "task_definition" {
  template = "${file("${"${path.module}/task_definition.json"}")}"

  vars {
    app_name = "${var.app_name}"
    app_base_url = "${var.domain}"
    app_protocol = "${var.app_protocol}"
    app_log_group = "${aws_cloudwatch_log_group.app.name}"
    image = "${aws_ecr_repository.app.repository_url}:latest"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                = "${var.app_name}"
  container_definitions = "${data.template_file.task_definition.rendered}"
}

resource "aws_ecs_service" "app" {
  name            = "${var.app_name}"
  cluster         = "${data.aws_ecs_cluster.app_cluster.id}"
  task_definition = "${aws_ecs_task_definition.app.arn}"
  desired_count   = 1

  load_balancer {
    target_group_arn = "${aws_alb_target_group.CCSDEV_app_cluster_alb_app_tg.arn}"
    container_name   = "${var.app_name}"
    container_port   = 8080
  }
}

##############################################################
# Pipeline
##############################################################
resource "aws_codepipeline" "app_pipeline" {
  name     = "${var.app_name}-pipeline"
  role_arn = "${data.aws_iam_role.codepipeline_app_service_role.arn}"

  artifact_store {
    location = "${data.aws_s3_bucket.build-artifacts.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["${var.app_name}_source"]

      configuration {
        Owner      = "${var.github_owner}"
        Repo       = "${var.github_repo}"
        Branch     = "${var.github_branch}"
        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["${var.app_name}_source"]
      output_artifacts = ["${var.app_name}_build"]
      version          = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.app.name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["${var.app_name}_build"]
      version         = "1"

      configuration {
        ClusterName = "${data.aws_ecs_cluster.app_cluster.cluster_name}"
        ServiceName = "${aws_ecs_service.app.name}"
        FileName    = "images.json"
      }
    }
  }
}