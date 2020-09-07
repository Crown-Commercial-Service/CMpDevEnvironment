##############################################################
# Whether the pipeline is enabled (terraform count workaround)  
##############################################################
variable enable {
    type = "string"
}

##############################################################
# Component Name
##############################################################
variable name {
    type = "string"
}

##############################################################
# Component source Github user/org
##############################################################
variable github_owner {
    type = "string"
}

##############################################################
# Component source Github repo
##############################################################
variable github_repo {
    type = "string"
}

##############################################################
# Component source Github branch
##############################################################
variable github_branch {
    type = "string"
    default = "master"
}

data "aws_caller_identity" "current" {
}

data "aws_region" "current" {}
