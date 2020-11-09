variable "artifacts_type" {}

variable "bootstrap_directory" {}

variable "bootstrap_tfplan_filename" {}

variable "build_api1_directory" {}

variable "build_api1_tfplan_filename" {}

variable "build_api2_directory" {}

variable "build_api2_tfplan_filename" {}

variable "build_app1_directory" {}

variable "build_app1_tfplan_filename" {}

variable "build_app2_directory" {}

variable "build_app2_tfplan_filename" {}

variable "build_cmp_maintenance_directory" {}

variable "build_cmp_maintenance_tfplan_filename" {}

variable "build_crown_marketplace_directory" {}

variable "build_crown_marketplace_tfplan_filename" {}

variable "build_crown_marketplace_legacy_directory" {}

variable "build_crown_marketplace_legacy_tfplan_filename" {}

variable "build_crown_marketplace_sidekiq_directory" {}

variable "build_crown_marketplace_sidekiq_tfplan_filename" {}

variable "build_crown_marketplace_upload_directory" {}

variable "build_crown_marketplace_upload_tfplan_filename" {}

variable "build_image_ruby_directory" {}

variable "build_image_ruby_tfplan_filename" {}

variable "build_npm1_directory" {}

variable "build_npm1_tfplan_filename" {}

variable "build_upload_supply_teacher_data_directory" {}

variable "build_upload_supply_teacher_data_tfplan_filename" {}

variable "cloudwatch_logs_group_name" {}

variable "codebuild_project_name" {}

variable "codebuild_service_role" {}

variable "environment_compute_type" {}

variable "environment_image" {}

variable "environment_type" {}

variable "infrastructure_directory" {}

variable "infrastructure_tfplan_filename" {}

variable "region" {
  default = "eu-west-2"
}

variable "security_directory" {}

variable "security_tfplan_filename" {}

variable "source_buildspec_filepath" {}

variable "source_type" {}

variable "ssm_config_directory" {}

variable "ssm_config_tfplan_filename" {}
