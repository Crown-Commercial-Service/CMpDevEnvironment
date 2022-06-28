module "ccsdev_scale_down_asg" {
  source           = "ccs-terraform/dfp-modules/aws//modules/scale_down_asg"
  version          = "1.0.0"
  min_size         = 0
  max_size         = 0
  desired_capacity = 0
  scale_down_cron  = "${var.scale_down_cron}"
}
