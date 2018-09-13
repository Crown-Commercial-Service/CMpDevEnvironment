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
  desired_count   = 1
  health_check_grace_period_seconds = 120

  load_balancer {
    target_group_arn = "${var.target_group_arn}"
    container_name   = "${var.task_name}"
    container_port   = 8080
  }
}
