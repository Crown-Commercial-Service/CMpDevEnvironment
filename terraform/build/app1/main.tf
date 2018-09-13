locals {
    domain = "roweitdev.co.uk"
    protocol = "http"
}

module "component" {
    source = "../../modules/component"

    type = "app"
    prefix = "ccs"
    name = "app1"
    build_type = "docker"
    github_owner = "RoweIT"
    github_repo = "CCSExampleApp1"
    cluster_name = "CCSDEV_app_cluster"
    environment = [
      {
        name = "CCS_APP_BASE_URL",
        value = "${local.domain}"
      },
      {
        name = "CCS_APP_PROTOCOL",
        value = "${local.protocol}"
      }, 
      {
        name = "CCS_FEATURE_EG1",
        value = "off"
      } 
    ]
    domain = "${local.domain}"
    port = "80"
    protocol = "${local.protocol}"   
}
