
variable artifact_prefix {
    type = "string"
}

variable artifact_name {
        type = "string"
}

variable build_type {
        type = "string"
}

variable service_role_arn {
    type = "string"
}

variable host_image {
        type = "string"
}

variable vpc_id {
        type = "string"
}

variable subnet_ids {
    type = "list"
}

variable security_group_ids {
    type = "list"
}

variable timeout {
    default = 5
}

variable host_compute_type {
    default = "BUILD_GENERAL1_SMALL"
}

variable host_type {
    default = "LINUX_CONTAINER"
}

variable host_is_privileged {
    default = true
}