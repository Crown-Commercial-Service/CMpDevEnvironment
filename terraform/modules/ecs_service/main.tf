##############################################################
#
# ECS Service module
#
##############################################################

resource "aws_ecs_task_definition" "task_definition" {
  family                = "${var.task_name}"
  container_definitions = "${var.task_definition}"
}

resource "aws_ecs_service" "service" {
  name            = "${var.task_name}"
  cluster         = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.task_definition.arn}"
  desired_count   = 1

  load_balancer {
    target_group_arn = "${var.target_group_arn}"
    container_name   = "${var.task_name}"
    container_port   = 8080
  }
}
