locals {
    domain = "ccsdev-internal.org"
    protocol = "http"
}

module "component" {
    source = "../../modules/component"

    type = "api"
    prefix = "ccs"
    name = "api1"
    build_type = "java"
    build_image = "aws/codebuild/java:openjdk-8"
    github_owner = "RoweIT"
    github_repo = "CCSExampleApi1"
    cluster_name = "CCSDEV_api_cluster"
    environment = [
      {
        name = "CCS_API_BASE_URL",
        value = "${local.domain}"
      },
      {
        name = "CCS_API_PROTOCOL",
        value = "${local.protocol}"
      }, 
      {
        name = "CCS_FEATURE_EG1",
        value = "on"
      } 
    ]
    domain = "${local.domain}"
    port = "80"
    protocol = "${local.protocol}"   
}
