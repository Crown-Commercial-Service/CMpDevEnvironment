##############################################################
# Whether the pipeline is enabled (terraform count workaround)  
##############################################################
variable enable {
    type = "string"
}

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
# Name of the build_test stage CodeBuild project
##############################################################
variable build_test_project_name {
    type = "string"
}

##############################################################
# Name of the build stage CodeBuild project
##############################################################
variable build_project_name {
    type = "string"
}

##############################################################
# Name of the deploy_test stage CodeBuild project
##############################################################
variable deploy_test_project_name {
    type = "string"
}

##############################################################
# ECS Cluster name for deployment
##############################################################
variable deploy_cluster_name {
    type = "string"
}

##############################################################
# ECS Service name for deployment
##############################################################
variable deploy_service_name {
    type = "string"
}

##############################################################
# ECS deployment task definition update filename
##############################################################
variable deploy_json_filename {
    type = "string"
    default = "images.json"
}