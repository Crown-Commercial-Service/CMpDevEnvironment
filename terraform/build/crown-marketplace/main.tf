module "component" {
    # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/component"
    source = "../../modules/component"

    environment_name = "Production"

    type = "app"
    prefix = "ccs"
    name = "cmp"
    hostname = "marketplace"
    build_type = "custom"
    build_image = "ccs/ruby"
    memory = 2560
    github_owner = "Crown-Commercial-Service"
    github_repo = "crown-marketplace"
    github_branch = "production"
    github_token_alias = "ccs-build_github_token"
    cluster_name = "CCSDEV_app_cluster"
    log_retention = "5"
    task_count = 3
    enable_tests = true
    enable_cognito_api_support = true
    environment = [
      {
        name = "RAILS_ENV",
        value = "production"
      },
      {
        name = "RAILS_SERVE_STATIC_FILES",
        value = "true"
      }
    ]
    port = "80"
}

