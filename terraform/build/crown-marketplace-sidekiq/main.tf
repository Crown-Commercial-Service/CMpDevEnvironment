###############################################################################
# This build pipeline is used to build and deploy a single instance of the
# marketplace application to the API Cluster.
#
# It's purposes is to run sidekiq for background processing tasks
###############################################################################
terraform {
  required_version = "~> 0.11"
}

module "component" {
    # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/component"
    source = "../../modules/component"
    environment_name = "Sandbox"
    type = "api"
    prefix = "ccs"
    name = "cmpsidekiq"
    routing_priority_offset = 300
    build_type = "custom"
    build_image = "ccs/ruby"

    # Build the standard marketplace application
    github_owner = "Crown-Commercial-Service"
    github_repo = "crown-marketplace"
    github_branch = "master"

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
