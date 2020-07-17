terraform {
  required_version = "~> 0.11"
}

module "component" {
    # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/component"
    source = "../../modules/component"

    # TODO (pillingworth, 2020-07-15) when crown-marketplace-legacy repo is available then copy build/crown-marketplace and rename with suffix -legacy
    type = "app"
    prefix = "ccs"
    name = "cmp-legacy"
    hostname = "app1"
    build_type = "docker"
    github_owner = "Crown-Commercial-Service"
    github_repo = "CMpExampleApp1"
    github_branch = "fm-application-separation"
    github_token_alias = "ccs-build_github_token"
    cluster_name = "CCSDEV_app_cluster"
    task_count = 1
    environment = [
      {
        name = "CCS_FEATURE_EG1",
        value = "off"
      } 
    ]
    port = "80"
}
