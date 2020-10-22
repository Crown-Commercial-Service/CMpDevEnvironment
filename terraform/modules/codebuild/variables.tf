variable "artifacts_type" {}

variable "bootstrap_directory" {}

variable "bootstrap_tfplan_filename" {}

variable "cloudwatch_logs_group_name" {}

variable "codebuild_project_name" {}

variable "codebuild_service_role" {}

variable "environment_compute_type" {}

variable "environment_image" {}

variable "environment_type" {}

variable "region" {
  default = "eu-west-2"
}

variable "source_buildspec_filepath" {}

variable "source_type" {}