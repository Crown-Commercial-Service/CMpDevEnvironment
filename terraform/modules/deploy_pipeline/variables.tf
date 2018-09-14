variable artifact_name {
    type = "string"
}

variable service_role_arn {
    type = "string"
}

variable artifact_bucket_name {
    type = "string"
}

variable github_owner {
    type = "string"
}

variable github_repo {
    type = "string"
}

variable github_branch {
    type = "string"
    default = "master"
}

variable build_project_name {
    type = "string"
}

variable deploy_cluster_name {
    type = "string"
}

variable deploy_service_name {
    type = "string"
}

variable deploy_json_filename {
    type = "string"
    default = "images.json"
}