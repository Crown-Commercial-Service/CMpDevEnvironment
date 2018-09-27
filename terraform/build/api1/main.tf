locals {
    api_domain = "internal.roweitdev.co.uk"
    app_domain = "roweitdev.co.uk"
    api_protocol = "http"
    app_protocol = "http"
}

module "component" {
    # source = "git::https://github.com/RoweIT/CCSDevEnvironment.git//terraform/modules/component"
    source = "../../modules/component"

    type = "api"
    prefix = "ccs"
    name = "api1"
    build_type = "java"
    github_owner = "RoweIT"
    github_repo = "CCSExampleApi1"
    github_token_alias = "ccs-build_github_token"
    cluster_name = "CCSDEV_api_cluster"
    task_count = 1
    environment = [
      {
        name = "CCS_APP_BASE_URL",
        value = "${local.app_domain}"
      },
      {
        name = "CCS_APP_PROTOCOL",
        value = "${local.app_protocol}"
      }, 
      {
        name = "CCS_API_BASE_URL",
        value = "${local.api_domain}"
      },
      {
        name = "CCS_API_PROTOCOL",
        value = "${local.api_protocol}"
      }, 
      {
        name = "CCS_FEATURE_EG1",
        value = "on"
      } 
    ]
    domain = "${local.api_domain}"
    port = "80"
    protocol = "${local.api_protocol}"   
}
