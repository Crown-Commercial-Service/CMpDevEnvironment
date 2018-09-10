##############################################################
#
# Application Configuration and Support
#
# Defines:
#   Application requirements
#
##############################################################
# Policies
##############################################################
data "aws_iam_policy_document" "codepipeline_app_service_role_assume_policy" {
  statement {
    principals = {
      type = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_app_service_role" {
  name                = "codepipeline-app-service-role"
  path                = "/"
  assume_role_policy  = "${data.aws_iam_policy_document.codepipeline_app_service_role_assume_policy.json}"
}

data "aws_iam_policy_document" "codepipeline_app_service_policy" {
  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
        "ecs:DescribeServices",
        "ecs:DescribeTaskDefinition",
        "ecs:DescribeTasks",
        "ecs:ListTasks",
        "ecs:RegisterTaskDefinition",
        "ecs:UpdateService"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject"
   ]

    resources = [
        "${data.aws_s3_bucket.build-artifacts.arn}",
        "${data.aws_s3_bucket.build-artifacts.arn}/*",
        "arn:aws:s3:::codepipeline*"
        ]
  }
}

resource "aws_iam_role_policy" "codepipeline_app_service_role_policy" {
  role = "${aws_iam_role.codepipeline_app_service_role.name}"
  name = "codepipeline_app_service_role_policy"
  policy = "${data.aws_iam_policy_document.codepipeline_app_service_policy.json}"
}

resource "aws_iam_role_policy_attachment" "codepipeline_container_registry_permissions" {
  role = "${aws_iam_role.codepipeline_app_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

##############################################################
# Build Artifact Storage
##############################################################
data "aws_s3_bucket" "build-artifacts" {
  bucket = "ccsdev-build-artifacts"
}

##############################################################
# Load Balancer configuration
##############################################################
resource "aws_alb_target_group" "CCSDEV_app_cluster_alb_app_tg" {
  name     = "CCSDEV-app-cluster-alb-app-tg"
  port     = "${var.http_port}"
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.CCSDEV-Services.id}"

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
    "Name" = "CCSDEV_app_cluster_alb_def-tg"
  }
}

resource "aws_alb_listener_rule" "subdomain_rule" {
  listener_arn = "${data.aws_alb_listener.http_listener.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.CCSDEV_app_cluster_alb_app_tg.arn}"
  }

  condition {
    field  = "host-header"
    values = ["app.${var.domain}"]
  }
}

##############################################################
# DNS configuration
##############################################################
resource "aws_route53_record" "app" {
  zone_id = "${data.aws_route53_zone.base_domain.zone_id}"
  name    = "app.${var.domain}"
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
    image = "${aws_ecr_repository.app.repository_url}:latest"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                = "app"
  container_definitions = "${data.template_file.task_definition.rendered}"
}

resource "aws_ecs_service" "app" {
  name            = "app"
  cluster         = "${data.aws_ecs_cluster.app_cluster.id}"
  task_definition = "${aws_ecs_task_definition.app.arn}"
  desired_count   = 1
#  iam_role        = "${aws_iam_role.foo.arn}"
#  depends_on      = ["aws_iam_role_policy.foo"]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.CCSDEV_app_cluster_alb_app_tg.arn}"
    container_name   = "app"
    container_port   = 8080
  }
}

##############################################################
# Pipeline
##############################################################
resource "aws_codepipeline" "app_pipeline" {
  name     = "app-pipeline"
  role_arn = "${aws_iam_role.codepipeline_app_service_role.arn}"

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
      output_artifacts = ["app_source"]

      configuration {
        Owner      = "RoweIT"
        Repo       = "CCSExampleApp1"
        Branch     = "master"
        PollForSourceChanges = false
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
      input_artifacts  = ["app_source"]
      output_artifacts = ["app_build"]
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
      input_artifacts = ["app_build"]
      version         = "1"

      configuration {
        ClusterName = "${data.aws_ecs_cluster.app_cluster.cluster_name}"
        ServiceName = "${aws_ecs_service.app.name}"
        FileName    = "images.json"
      }
    }
  }
}