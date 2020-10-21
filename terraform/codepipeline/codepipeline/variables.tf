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
  default = "cmp_terraform_codepipeline_role"
}

variable "output_artifact" {
  default = "CMpDevEnvironment_Sandbox_Source"
}