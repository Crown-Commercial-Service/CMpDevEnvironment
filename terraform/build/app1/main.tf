module "component" {
    # source = "git::https://github.com/RoweIT/CCSDevEnvironment.git//terraform/modules/component"
    source = "../../modules/component"

    type = "app"
    prefix = "ccs"
    name = "app1"
    build_type = "docker"
    github_owner = "RoweIT"
    github_repo = "CCSExampleApp1"
    github_token_alias = "ccs-build_github_token"
    cluster_name = "CCSDEV_app_cluster"
    task_count = 1
    environment = [
      {
        name = "CCS_FEATURE_EG1",
        value = "off"
      } 
    ]
    port = "80"
}
