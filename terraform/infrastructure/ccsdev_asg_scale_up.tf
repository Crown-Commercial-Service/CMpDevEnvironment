#module "ccsdev_scale_up_asg" {
#  source           = "ccs-terraform/dfp-modules/aws//modules/scale_up_asg"
#  version          = "1.0.0"
#  min_size         = 1
#  max_size         = 1
#  desired_capacity = 1
#  scale_up_cron    = "${var.scale_up_cron}"
#}

#module "ccsdev_app_scale_up_asg" {
#  source           = "ccs-terraform/dfp-modules/aws//modules/app_scale_up_asg"
#  version          = "1.0.0"
#  min_size         = 3
#  max_size         = 4
#  desired_capacity = 3
#  scale_up_cron    = "${var.scale_up_cron}"
#}
