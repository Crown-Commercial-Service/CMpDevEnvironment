terraform {
  required_version = "~> 0.11"
}

module "component" {
    # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/component"
    source = "../../modules/component"

    environment_name = "Preview"

    type = "api"
    prefix = "ccs"
    name = "api1"
    routing_priority_offset = 900
    build_type = "java"
    github_owner = "Crown-Commercial-Service"
    github_repo = "CMpExampleApi1"
    github_branch = "master"
    github_token_alias = "ccs-build_github_token"
    cluster_name = "CCSDEV_api_cluster"
    task_count = 1
    enable_tests = true
    environment = [
      {
        name = "CCS_FEATURE_EG1",
        value = "on"
      } 
    ]
    port = "80"
    providers = {
      aws = "aws"
    }
}
