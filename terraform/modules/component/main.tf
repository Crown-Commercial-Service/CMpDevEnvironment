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
# S3 Bucket name
##############################################################

locals {
   artifact_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.build-artifacts"
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
  service_role_arn = "${data.aws_iam_role.codebuild_service_role.arn}"
  vpc_id = "${data.aws_vpc.CCSDEV-Services.id}"
  subnet_ids = ["${data.aws_subnet.CCSDEV-AZ-a-Private-1.id}"]
  security_group_ids = ["${data.aws_security_group.vpc-CCSDEV-internal.id}"]
}

##############################################################
# Cloudwatch Logs
##############################################################
resource "aws_cloudwatch_log_group" "component" {
  name = "/ccs/${var.name}"
  retention_in_days = 3
}

##############################################################
# ECS configuration
##############################################################

module "ecs_service" {
  source = "../ecs_service"

  task_name = "${var.name}"
  task_count = "${var.task_count}"
  task_environment = "${var.environment}"
  log_group = "${aws_cloudwatch_log_group.component.name}"
  cluster_name = "${var.cluster_name}"
  image = "${module.build.image_name}"
  target_group_arn = "${module.routing.target_group_arn}"
}

##############################################################
# Pipeline
##############################################################
module "pipeline" {
  source = "../deploy_pipeline"

  artifact_name = "${var.name}"
  service_role_arn = "${data.aws_iam_role.codepipeline_service_role.arn}"
  artifact_bucket_name = "${local.artifact_bucket_name}"
  github_owner = "${var.github_owner}"
  github_repo = "${var.github_repo}"
  build_project_name = "${module.build.project_name}"
  deploy_cluster_name = "${var.cluster_name}"
  deploy_service_name = "${module.ecs_service.name}"
}

##############################################################
# Routing
##############################################################
module "routing" {
  source = "../routing"

  type     = "${var.type}"
  name     = "${var.name}"
  domain   = "${var.domain}"
  port     = "${var.port}"
  protocol = "${var.protocol}"
}