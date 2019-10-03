module "component" {
    # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/component"
    source = "../../modules/component"

    environment_name = "FMPreview"

    type = "app"
    prefix = "ccs"
    name = "cmp"
    build_type = "custom"
    build_image = "ccs/ruby"
    github_owner = "Crown-Commercial-Service"
    github_repo = "crown-marketplace"
    github_branch = "master"
    github_token_alias = "ccs-build_github_token"
    cluster_name = "CCSDEV_app_cluster"
    log_retention = "3"
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
