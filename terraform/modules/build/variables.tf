##############################################################
# Build Artifact (Container) Prefix  
##############################################################
variable artifact_prefix {
    type = "string"
}

##############################################################
# Build Artifact (Container) Name  
##############################################################
variable artifact_name {
    type = "string"
}

##############################################################
# Github Owner  
##############################################################
variable github_owner {
    type = "string"
}

##############################################################
# Github Repo
##############################################################
variable github_repo {
    type = "string"
}

##############################################################
# Github Branch
##############################################################
variable github_branch {
    type = "string"
    default = "master"
}

##############################################################
# Build Type (docker, java, etc.) see build module for options
##############################################################
variable build_type {
    type = "string"
}

variable build_image {
    type = "string"
    default = ""
}

variable build_image_version {
    type = "string"
    default = "latest"
}

variable enable_tests {
    type = "string"
    default = false
}
##############################################################
# AWS IAM role providing build permissions
##############################################################
variable service_role_arn {
    type = "string"
}

##############################################################
# Environment that the build is linked to
##############################################################
variable "environment_name" {
    default = "Development"
}

##############################################################
# VPC that the build will run within
##############################################################
variable vpc_id {
    type = "string"
}

##############################################################
# Subnets that the build will run within
##############################################################
variable subnet_ids {
    type = "list"
}

##############################################################
# Security Groups that secure the build process
##############################################################
variable security_group_ids {
    type = "list"
}

##############################################################
# Build timeout in minutes
##############################################################
variable timeout {
    default = 30
}

##############################################################
# Build compute size
##############################################################
variable host_compute_type {
    default = "BUILD_GENERAL1_SMALL"
}

##############################################################
# Build host type
##############################################################
variable host_type {
    default = "LINUX_CONTAINER"
}

##############################################################
# Required if Docker is used within build
##############################################################
variable host_is_privileged {
    default = true
}