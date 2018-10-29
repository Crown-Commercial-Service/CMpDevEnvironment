##############################################################
# Build Artifact (Container) Name  
##############################################################
variable artifact_name {
    type = "string"
}

##############################################################
# AWS IAM role providing build permissions
##############################################################
variable service_role_arn {
    type = "string"
}

##############################################################
# S3 Bucket Name for storing build artifacts
##############################################################
variable artifact_bucket_name {
    type = "string"
}

##############################################################
# Source Github user/org
##############################################################
variable github_owner {
    type = "string"
}

##############################################################
# Source Github repo
##############################################################
variable github_repo {
    type = "string"
}

##############################################################
# Source Github branch
##############################################################
variable github_branch {
    type = "string"
    default = "master"
}

##############################################################
# Source Github token alias as used in the Parameter Store
##############################################################
variable github_token_alias {
    type = "string"
}

##############################################################
# Name of the build stage CodeBuild project
##############################################################
variable build_project_name {
    type = "string"
}
