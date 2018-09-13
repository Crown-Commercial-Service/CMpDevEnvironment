variable task_name {
    type = "string"
}

variable task_environment {
    type = "list"
    default = []
}

variable log_group {
    type = "string"
}

variable cluster_name {
    type = "string"
}

variable image {
    type = "string"
}

variable target_group_arn {
    type = "string"
}
