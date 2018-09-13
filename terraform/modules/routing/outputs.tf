##############################################################
# Routed Target Group
##############################################################
output "target_group_arn" {
  value = "${aws_alb_target_group.component.arn}"
}
