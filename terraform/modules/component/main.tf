##############################################################
#
# Component (App / Api) module
#
##############################################################
# Type validation
# See https://github.com/hashicorp/terraform/issues/15469
##############################################################
variable "__valid_component_types__" {
  description = "Valid component types - Do Not Override"
  type = "list"
  default = ["api", "app"]
}

resource "null_resource" "is_component_type_valid" {
  count = "${contains(var.__valid_component_types__, var.type) == true ? 0 : 1}"
  "${format("Component <type> must be one of %s", join(", ", var.__valid_component_types__))}" = true
}

##############################################################
# "Proxy" provider; provider must be passed into the module
##############################################################
provider "aws" {
}

##############################################################
# Infrastructure config
##############################################################

locals {
  artifact_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.build-artifacts"
}

data "aws_ssm_parameter" "domain_name" {
  name = "/${var.environment_name}/config/domain_name"
}

data "aws_ssm_parameter" "domain_prefix" {
  name = "/${var.environment_name}/config/domain_prefix"
}

data "aws_ssm_parameter" "enable_https" {
  name = "/${var.environment_name}/config/enable_https"
}

data "aws_ssm_parameter" "db_config_url" {
  name = "/${var.environment_name}/config/rds_url"
}

data "aws_ssm_parameter" "db_config_type" {
  name = "/${var.environment_name}/config/rds_type"
}

data "aws_ssm_parameter" "db_config_host" {
  name = "/${var.environment_name}/config/rds_host"
}

data "aws_ssm_parameter" "db_config_port" {
  name = "/${var.environment_name}/config/rds_port"
}

data "aws_ssm_parameter" "redis_config_host" {
  name = "/${var.environment_name}/config/redis_host"
}

data "aws_ssm_parameter" "redis_config_port" {
  name = "/${var.environment_name}/config/redis_port"
}

data "aws_ssm_parameter" "db_config_name" {
  name = "/${var.environment_name}/config/rds_name"
}

data "aws_ssm_parameter" "db_config_username" {
  name = "/${var.environment_name}/config/rds_username"
}

data "aws_ssm_parameter" "db_config_password" {
  name = "/${var.environment_name}/config/rds_password"
}

data "aws_ssm_parameter" "config_es_endpoint" {
  name = "/${var.environment_name}/config/es_endpoint"
}

data "aws_ssm_parameter" "config_s3_app_api_data_bucket" {
  name = "/${var.environment_name}/config/app_api_data_bucket"
}

##############################################################
# Subdomain
##############################################################

locals {
  config_hostname = "${var.hostname=="" ? var.name : var.hostname}"
}

##############################################################
# Build
##############################################################
module "build" {
  source = "../build"

  artifact_prefix = "${var.prefix}"
  artifact_name = "${var.name}"
  github_owner = "${var.github_owner}"
  github_repo = "${var.github_repo}"
  github_branch = "${var.github_branch}"
  build_type = "${var.build_type}"
  build_image = "${var.build_image}"
  build_image_version = "${var.build_image_version}"
  enable_tests = "${var.enable_tests}"
  service_role_arn = "${data.aws_iam_role.codebuild_service_role.arn}"
  vpc_id = "${data.aws_vpc.CCSDEV-Services.id}"
  subnet_ids = ["${data.aws_subnet.CCSDEV-AZ-a-Private-1.id}", "${data.aws_subnet.CCSDEV-AZ-b-Private-1.id}", "${data.aws_subnet.CCSDEV-AZ-c-Private-1.id}"]
  security_group_ids = ["${data.aws_security_group.vpc-CCSDEV-internal.id}"]
}

##############################################################
# Cloudwatch Logs
##############################################################
resource "aws_cloudwatch_log_group" "component" {
  name = "/${var.prefix}/${var.name}"
  retention_in_days = "${var.log_retention}"
  
  tags {
    Name = "Infrastructure configured Cloudwatch Log Group"
    CCSRole = "Infrastructure"
  }
}

##############################################################
# ECS configuration
##############################################################

locals {
    config_protocol = "${data.aws_ssm_parameter.enable_https.value ? "https": "http" }"
    config_app_domain = "${data.aws_ssm_parameter.domain_name.value}"
    config_api_domain = "${data.aws_ssm_parameter.domain_prefix.value}.${data.aws_ssm_parameter.domain_name.value}"

    config_domain = "${var.type == "app" ? local.config_app_domain : local.config_api_domain}"
    config_environment = [
      {
        name = "CCS_HOSTNAME",
        value = "${local.config_hostname}"
      },
      {
        name = "CCS_APP_BASE_URL",
        value = "${local.config_app_domain}"
      },
      {
        name = "CCS_APP_PROTOCOL",
        value = "${local.config_protocol}"
      }, 
      {
        name = "CCS_API_BASE_URL",
        value = "${local.config_api_domain}"
      },
      {
        name = "CCS_API_PROTOCOL",
        value = "${local.config_protocol}"
      },
      {
        name = "CCS_DEFAULT_DB_URL",
        value = "${data.aws_ssm_parameter.db_config_url.value}"
      }, 
      {
        name = "CCS_DEFAULT_DB_TYPE",
        value = "${data.aws_ssm_parameter.db_config_type.value}"
      }, 
      {
        name = "CCS_DEFAULT_DB_HOST",
        value = "${data.aws_ssm_parameter.db_config_host.value}"
      }, 
      {
        name = "CCS_DEFAULT_DB_PORT",
        value = "${data.aws_ssm_parameter.db_config_port.value}"
      }, 
      {
        name = "CCS_REDIS_HOST",
        value = "${data.aws_ssm_parameter.redis_config_host.value}"
      }, 
      {
        name = "CCS_REDIS_PORT",
        value = "${data.aws_ssm_parameter.redis_config_port.value}"
      }, 
      {
        name = "CCS_DEFAULT_DB_NAME",
        value = "${data.aws_ssm_parameter.db_config_name.value}"
      }, 
      {
        name = "CCS_DEFAULT_DB_USER",
        value = "${data.aws_ssm_parameter.db_config_username.value}"
      }, 
      {
        name = "CCS_DEFAULT_DB_PASSWORD",
        value = "${data.aws_ssm_parameter.db_config_password.value}"
      }, 
      {
        name = "CCS_DEFAULT_ES_ENDPOINT",
        value = "${data.aws_ssm_parameter.config_es_endpoint.value}"
      },
      {
        name = "CCS_APP_API_DATA_BUCKET",
        value = "${data.aws_ssm_parameter.config_s3_app_api_data_bucket.value}"
      }
    ]
}

module "ecs_service" {
  source = "../ecs_service"

  task_name = "${var.name}"
  task_count = "${var.task_count}"
  autoscaling_min_count = "${var.autoscaling_min_count}"
  autoscaling_max_count = "${var.autoscaling_max_count}"
  task_environment = "${concat(local.config_environment, var.environment)}"
  log_group = "${aws_cloudwatch_log_group.component.name}"
  cluster_name = "${var.cluster_name}"
  image = "${module.build.image_name}"
  target_group_arn = "${module.routing.target_group_arn}"
  ecs_service_arn = "${data.aws_iam_role.codepipeline_service_role.arn}"
}

##############################################################
# Pipeline
##############################################################
locals {
  test_count = "${var.enable_tests ? 1 : 0}"
  no_test_count = "${local.test_count ? 0 : 1}"
}

module "test_deploy_pipeline" {
  enable = "${local.test_count}"
  source = "../test_deploy_pipeline"

  artifact_name = "${var.name}"
  service_role_arn = "${data.aws_iam_role.codepipeline_service_role.arn}"
  artifact_bucket_name = "${local.artifact_bucket_name}"
  github_owner = "${var.github_owner}"
  github_repo = "${var.github_repo}"
  github_branch = "${var.github_branch}"
  github_token_alias = "${var.github_token_alias}"
  build_test_project_name = "${module.build.build_test_project_name}"
  deploy_test_project_name = "${module.build.deploy_test_project_name}"
  build_project_name = "${module.build.build_project_name}"
  deploy_cluster_name = "${var.cluster_name}"
  deploy_service_name = "${module.ecs_service.name}"
}

module "deploy_pipeline" {
  enable = "${local.no_test_count}"
  source = "../deploy_pipeline"

  artifact_name = "${var.name}"
  service_role_arn = "${data.aws_iam_role.codepipeline_service_role.arn}"
  artifact_bucket_name = "${local.artifact_bucket_name}"
  github_owner = "${var.github_owner}"
  github_repo = "${var.github_repo}"
  github_branch = "${var.github_branch}"
  github_token_alias = "${var.github_token_alias}"
  build_project_name = "${module.build.build_project_name}"
  deploy_cluster_name = "${var.cluster_name}"
  deploy_service_name = "${module.ecs_service.name}"
}

##############################################################
# Routing
##############################################################
module "routing" {
  source = "../routing"

  type      = "${var.type}"
  name      = "${var.name}"
  domain    = "${local.config_domain}"
  catch_all = "${var.catch_all}"
  routing_priority_offset = "${var.routing_priority_offset}"
  protocol  = "${local.config_protocol}"
  hostname  = "${local.config_hostname}"
  port      = "${var.port}"
  path_pattern = "${var.path_pattern}"
  health_check_path = "${var.health_check_path}"
  providers = {
    aws = "aws"
  }    
}
