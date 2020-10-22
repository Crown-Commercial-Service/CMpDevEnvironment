data "aws_caller_identity" "current" {}

locals {
  artifact_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.build-artifacts"
}

variable "codepipeline_name" {
  default = "cmp_terraform_codepipeline"
}

variable "github_branch" {
  default = "sandbox"
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

variable "iam_role_name" {
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
