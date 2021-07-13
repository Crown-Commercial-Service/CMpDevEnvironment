terraform {
  required_version = "~> 0.11"
}

# TODO (pillingworth, 2020-07-15) when crown-marketplace-legacy repo is
# available then update the github_repo variable below
module "component" {
    # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/component"
    source = "../../modules/legacy_component"
    environment_name = "Development"
#   environment_name = "Sandbox"
    type = "app"
    prefix = "ccs"
    name = "cmp-legacy"
    path_patterns = ["/management-consultancy*", "/supply-teachers*", "/legal-services*"]
    register_dns_record = true
    hostname = "cmp"
    # note as part of sept2020 changes and a swapping priorities of crown-marketplace and
    # crown-marketplace-legacy over cannot simply swap numbers as when run terrafrom it
    # can't swap as prioriy in use; instead increase both by one so swapping to a new number
    routing_priority_offset = 101
    build_type = "custom"
    build_image = "ccs/ruby"
    github_owner = "Crown-Commercial-Service"
    github_repo = "crown-marketplace-legacy"
    github_branch = "master"
#   github_branch = "develop"
    github_token_alias = "ccs-build_github_token"
    cluster_name = "CCSDEV_app_cluster"
    task_count = 2
    autoscaling_max_count = 4
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
    providers = {
      aws = "aws"
    }    
}

