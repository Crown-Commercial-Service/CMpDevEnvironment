data "aws_caller_identity" "current" {}

locals {
  artifact_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.build-artifacts"
}

variable "codepipeline_name" {
  default = "cmp_terraform_codepipeline"
}

variable "github_branch" {
  default = "sandbox-codepipeline"
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

variable "terraform_apply_artifact" {
  default = "CMpDevEnvironment_Sandbox_Terraform_Apply_Artifact"
}

# Variables for the Terraform plan codebuild project
variable "codebuild_terraform_plan_artifact_type" {
  default = "CODEPIPELINE"
}

variable "codebuild_terraform_apply_artifact_type" {
  default = "CODEPIPELINE"
}

variable "bootstrap_directory" {
  default = "terraform/bootstrap/"
}

variable "bootstrap_tfplan_filename" {
  default = "bootstrap_tfplan"
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

variable "build_image_ruby_directory" {
  default = "terraform/build/image-ruby/"
}

variable "build_image_ruby_tfplan_filename" {
  default = "build_image_ruby_tfplan"
}

variable "codebuild_terraform_plan_cloudwatch_logs_group_name" {
  default = "cmp-terraform-plan-cloudwatch-logs"
}

variable "codebuild_terraform_apply_cloudwatch_logs_group_name" {
  default = "cmp-terraform-apply-cloudwatch-logs"
}

variable "codebuild_terraform_plan_project_name" {
  default = "cmp-terraform-plan"
}

variable "codebuild_terraform_apply_project_name" {
  default = "cmp-terraform-apply"
}

variable "codebuild_terraform_plan_environment_compute_type" {
  default = "BUILD_GENERAL1_SMALL"
}

variable "codebuild_terraform_apply_environment_compute_type" {
  default = "BUILD_GENERAL1_SMALL"
}

variable "codebuild_terraform_plan_environment_image" {
  default = "aws/codebuild/standard:4.0"
}

variable "codebuild_terraform_apply_environment_image" {
  default = "aws/codebuild/standard:4.0"
}

variable "codebuild_terraform_plan_environment_type" {
  default = "LINUX_CONTAINER"
}

variable "codebuild_terraform_apply_environment_type" {
  default = "LINUX_CONTAINER"
}

variable "codebuild_terraform_plan_source_buildspec_filepath" {
  default = "buildspecs/buildspec_terraform_plan_sandbox.yml"
}

variable "codebuild_terraform_apply_source_buildspec_filepath" {
  default = "buildspecs/buildspec_terraform_apply_sandbox.yml"
}

variable "codebuild_terraform_plan_source_type" {
  default = "CODEPIPELINE"
}

variable "codebuild_terraform_apply_source_type" {
  default = "CODEPIPELINE"
}

variable "infrastructure_directory" {
  default = "terraform/infrastructure/"
}

variable "infrastructure_tfplan_filename" {
  default = "infrastructure_tfplan"
}
