##############################################################
# AWS Task Definition name
##############################################################
variable task_name {
    type = "string"
}

##############################################################
# Any environment variables to run within the container
#  when deployed within ECS, e.g.
#
# [
#   { name = "ENV_VAR_1", value = "123"},
#   { name = "ENV_VAR_2", value = "abc"} 
# ]
##############################################################
variable task_environment {
    type = "list"
    default = []
}

##############################################################
# Desired task count
##############################################################
variable task_count {
    type = "string"
    default = 1
}

##############################################################
# Autoscaling task counts
##############################################################
variable autoscaling_min_count {
    type = "string"
    default = -1
}

variable autoscaling_max_count {
    type = "string"
    default = -1
}

variable ecs_service_arn {
    type = "string"
}
##############################################################
# AWS Cloudwatch Log Group name
##############################################################
variable log_group {
    type = "string"
}

##############################################################
# AWS ECS Cluster name
##############################################################
variable cluster_name {
    type = "string"
}

##############################################################
# Fully Qualified ECS Image Repository URL
##############################################################
variable image {
    type = "string"
}

##############################################################
# Application Load Balancer Target Group for the Service/Task
##############################################################
variable target_group_arn {
    type = "string"
}

variable "memory" {
    type = "string"
}