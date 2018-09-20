locals {
    api_domain = "ccsdev-internal.org"
    app_domain = "roweitdev.co.uk"
    api_protocol = "http"
    app_protocol = "http"
}

module "component" {
    # source = "git::https://github.com/RoweIT/CCSDevEnvironment.git//terraform/modules/component"
    source = "../../modules/component"

    type = "app"
    prefix = "ccs"
    name = "app2"
    build_type = "docker"
    github_owner = "RoweIT"
    github_repo = "CCSExampleApp2"
    cluster_name = "CCSDEV_app_cluster"
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
        value = "off"
      } 
    ]
    domain = "${local.app_domain}"
    port = "80"
    protocol = "${local.app_protocol}"   
}
