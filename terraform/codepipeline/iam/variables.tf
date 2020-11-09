variable "codebuild_iam_role_name" {
  default = "cmp-terraform-codebuild-role"
}

variable "codepipeline_iam_role_name" {
  default = "cmp-terraform-codepipeline-role"
}

variable "region" {
  default = "eu-west-2"
}
