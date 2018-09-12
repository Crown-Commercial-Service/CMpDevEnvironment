variable artifact_name {}

variable service_role_arn {}

variable artifact_bucket {}

variable github_owner {}

variable github_repo {}

variable github_branch {
    default = "master"
}

variable build_project_name {}

variable deploy_cluster_name {}

variable deploy_service_name {}

variable deploy_json_filename {
    default = "images.json"
}