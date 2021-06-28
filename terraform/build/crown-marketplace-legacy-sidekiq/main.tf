terraform {
  required_version = "~> 0.11"
}

module "component" {
    # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/legacy_component"
    source = "../../modules/legacy_component"
    environment_name = "Development"
    type = "api"
    prefix = "ccs"
    name = "legacy-skiq"
    routing_priority_offset = 301
    build_type = "custom"
    build_image = "ccs/ruby"
    github_owner = "Crown-Commercial-Service"
    github_repo = "crown-marketplace-legacy"
    github_branch = "develop"

    github_token_alias = "ccs-build_github_token"
    cluster_name = "CCSDEV_api_cluster"
    task_count = 1
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
      },
      {
        # Set to enable Sidekiq
        name = "APP_RUN_SIDEKIQ",
        value = "true"
      }
    ]
    port = "80"
    providers = {
      aws = "aws"
    }
}

