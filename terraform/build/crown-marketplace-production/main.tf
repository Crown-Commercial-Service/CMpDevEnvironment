module "component" {
    # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/component"
    source = "../../modules/component"

    environment_name = "Production"

    type = "app"
    prefix = "ccs"
    name = "cmpprod"
    hostname = "marketplace"
    build_type = "custom"
    build_image = "ccs/ruby"
    github_owner = "Crown-Commercial-Service"
    github_repo = "crown-marketplace"
    github_branch = "production"
    github_token_alias = "ccs-build_github_token"
    cluster_name = "CCSDEV_app_cluster"
    log_retention = "3"
    task_count = 3
    enable_tests = true
    enable_cognito_support = true
    cognito_login_callback = "auth/cognito/callback"
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
