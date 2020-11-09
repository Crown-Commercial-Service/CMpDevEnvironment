data "aws_caller_identity" "current" {}

locals {
  artifact_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.build-artifacts"
}

variable "codepipeline_name" {
  default = "cmp_terraform_codepipeline"
}

variable "github_branch" {
  default = "sandbox-terraform-codepipeline"
}

variable "github_owner" {
  default = "Crown-Commercial-Service"
}

variable "github_repository" {
  default = "CMpDevEnvironment"
}

variable "github_token_alias" {
  default = "ccs-build_github_token"
}

variable "codebuild_iam_role_name" {
  default = "cmp-terraform-codebuild-role"
}

variable "codepipeline_iam_role_name" {
  default = "cmp-terraform-codepipeline-role"
}

variable "region" {
  default = "eu-west-2"
}

variable "source_artifact" {
  default = "CMpDevEnvironment_Sandbox_Source_Artifact"
}

variable "terraform_plan_artifact" {
  default = "CMpDevEnvironment_Sandbox_Terraform_Plan_Artifact"
}

# Variables for the Terraform plan codebuild project
variable "codebuild_terraform_plan_artifact_type" {
  default = "CODEPIPELINE"
}

variable "bootstrap_directory" {
  default = "terraform/bootstrap/"
}

variable "bootstrap_tfplan_filename" {
  default = "bootstrap_tfplan"
}

variable "build_api1_directory" {
  default = "terraform/build/api1/"
}

variable "build_api1_tfplan_filename" {
  default = "build_api1_tfplan"
}

variable "build_api2_directory" {
  default = "terraform/build/api2/"
}

variable "build_api2_tfplan_filename" {
  default = "build_api2_tfplan"
}

variable "build_app1_directory" {
  default = "terraform/build/app1/"
}

variable "build_app1_tfplan_filename" {
  default = "build_app1_tfplan"
}

variable "build_app2_directory" {
  default = "terraform/build/app2/"
}

variable "build_app2_tfplan_filename" {
  default = "build_app2_tfplan"
}

variable "build_cmp_maintenance_directory" {
  default = "terraform/build/cmp-maintenance/"
}

variable "build_cmp_maintenance_tfplan_filename" {
  default = "build_cmp_maintenance_tfplan"
}

variable "build_crown_marketplace_directory" {
  default = "terraform/build/crown-marketplace/"
}

variable "build_crown_marketplace_tfplan_filename" {
  default = "build_crown_marketplace_tfplan"
}

variable "build_crown_marketplace_legacy_directory" {
  default = "terraform/build/crown-marketplace-legacy/"
}

variable "build_crown_marketplace_legacy_tfplan_filename" {
  default = "build_cmp_legacy_tfplan"
}

variable "build_crown_marketplace_sidekiq_directory" {
  default = "terraform/build/crown-marketplace-sidekiq/"
}

variable "build_crown_marketplace_sidekiq_tfplan_filename" {
  default = "build_cmp_sidekiq_tfplan"
}

variable "build_crown_marketplace_upload_directory" {
  default = "terraform/build/crown-marketplace-upload/"
}

variable "build_crown_marketplace_upload_tfplan_filename" {
  default = "build_cmp_upload_tfplan"
}

variable "build_image_ruby_directory" {
  default = "terraform/build/image-ruby/"
}

variable "build_image_ruby_tfplan_filename" {
  default = "build_image_ruby_tfplan"
}

variable "build_npm1_directory" {
  default = "terraform/build/npm1/"
}

variable "build_npm1_tfplan_filename" {
  default = "build_npm1_tfplan"
}

variable "build_upload_supply_teacher_data_directory" {
  default = "terraform/build/upload-supply-teacher-data/"
}

variable "build_upload_supply_teacher_data_tfplan_filename" {
  default = "build_upload_supply_teacher_data_tfplan"
}

variable "codebuild_terraform_plan_cloudwatch_logs_group_name" {
  default = "cmp-terraform-plan-cloudwatch-logs"
}

variable "codebuild_terraform_plan_project_name" {
  default = "cmp-terraform-plan"
}

variable "codebuild_terraform_plan_environment_compute_type" {
  default = "BUILD_GENERAL1_SMALL"
}

variable "codebuild_terraform_plan_environment_image" {
  default = "aws/codebuild/standard:4.0"
}

variable "codebuild_terraform_plan_environment_type" {
  default = "LINUX_CONTAINER"
}

variable "codebuild_terraform_plan_source_buildspec_filepath" {
  default = "buildspecs/buildspec_terraform_plan_sandbox.yml"
}

variable "codebuild_terraform_plan_source_type" {
  default = "CODEPIPELINE"
}

variable "infrastructure_directory" {
  default = "terraform/infrastructure/"
}

variable "infrastructure_tfplan_filename" {
  default = "infrastructure_tfplan"
}

variable "security_directory" {
  default = "terraform/security/"
}

variable "security_tfplan_filename" {
  default = "security_tfplan"
}

variable "ssm_config_directory" {
  default = "terraform/ssm-config/"
}

variable "ssm_config_tfplan_filename" {
  default = "ssm_config_tfplan"
}
