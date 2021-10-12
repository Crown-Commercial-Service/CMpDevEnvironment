##############################################################
#
# AWS Details
#
# NOTE: Access Key and Secret Key will be pulled from the local
# credentials
#
# ##############################################################

variable "region" {
  default = "eu-west-2"
}

data "aws_caller_identity" "current" {}

variable "environment_name" {
  default = "Preview"
}

variable "shared_postcode_data_bucket" {
  type = "string"
  default = ""
}

variable ccs_cognito_groups {
  type    = "map"
  default = {
    "at_access" = "Apprenticeships user access",
    "buyer" = "Buyer user access",
    "supplier" = "Supplier user access",
    "ccs_employee" = "CCS Employee user access",
    "fm_access" = "Facilities Management user access",
    "ls_access" = "Legal Services user access",
    "mc_access" = "Management Consultancy user access",
    "st_access" = "Supply Teachers user access"  }
}

##############################################################
# Bastion host server settings
##############################################################

variable "bastion_ami" {
  default = "ami-06dc09bb8854cbde3"
}

variable "bastion_desired_instance_count" {
  default = 1
}

variable "bastion_instance_class" {
  default = "t2.micro"
}

variable "bastion_key_name" {
  default = "ccs_bastion"
}

variable "bastion_max_instance_count" {
  default = 1
}

variable "bastion_min_instance_count" {
  default = 1
}

variable "bastion_ssh_ciphers" {
  type = "string"
  default = ""
}

variable "bastion_storage" {
  default = 8
}

##############################################################
# cluster domain
##############################################################

variable domain_name {
  type = "string"
  default = ""
}

variable domain_internal_prefix {
  type = "string"
  default = "internal"
}

variable enable_https {
  type = "string"
  default = true
}
##############################################################
# cluster settings - Application
##############################################################

variable "app_cluster_ami" {
   default = "ami-079ce1ec8fac4f8b0"
}

variable "app_cluster_instance_class" {
  default = "m4.large"
}

variable "app_cluster_desired_instance_count" {
  default = "4"
}

variable "app_cluster_min_instance_count" {
  default = "4"
}

variable "app_cluster_max_instance_count" {
  default = "5"
}

variable "app_cluster_key_name" {
  default = "ccs_cluster"
}

variable "app_cluster_alb_logging_enabled" {
  default = true
}

##############################################################
# cluster settings - APIs
##############################################################

variable "api_cluster_ami" {
  default = "ami-079ce1ec8fac4f8b0"
}

variable "api_cluster_instance_class" {
  default = "m4.large"
}

variable "api_cluster_min_instance_count" {
  default = "1"
}

variable "api_cluster_max_instance_count" {
  default = "1"
}

variable "api_cluster_desired_instance_count" {
  default = "1"
}

variable "api_cluster_key_name" {
  default = "ccs_cluster"
}

variable "api_cluster_alb_logging_enabled" {
  default = false
}

##############################################################
# Default Databases Settings
##############################################################
variable "create_default_rds_database" {
  default = true
}

variable "default_db_instance_class" {
  default = "db.t2.medium"
}

variable "default_db_storage" {
  default = 100
}

variable "default_db_apply_immediately" {
  default = false
}

variable "default_db_type" {
  default = "postgresql"
}

variable "default_db_host" {
  default = ""
}

variable "default_db_port" {
  default = "5432"
}

variable "default_db_name" {
  default = "cmpdefault"
}

variable "default_db_username" {
  default = "ccsdev"
}

variable "default_db_password" {
  default = ""
}

variable "default_db_retention_period" {
  default = "7"
}

##############################################################
# ElasticCache - Redis settings
##############################################################
variable "create_elasticache_redis" {
  default = true
}

variable "elasticache_instance_class" {
  default = "cache.t2.medium"
}

##############################################################
# Alarms and Dashboards
##############################################################

variable "create_cloudwatch_alarms" {
  default = true
}

##############################################################
# Elastic Search Settings
##############################################################

variable "create_elasticsearch_default_domain" {
  default = false
}

variable "elasticsearch_default_domain" {
  default = "cmpdefault"
}

variable "elasticsearch_default_instance_class" {
  default = "c4.large.elasticsearch"
}

##############################################################
# External access
##############################################################
variable ssh_access_cidrs {
  type    = "map"
  default = {}
}

variable app_access_cidrs {
  type    = "map"
  default = {}
}

##############################################################
# Common port constants
##############################################################

variable "ssh_port" {
  default = 22
}

variable "http_port" {
  default = 80
}

variable "https_port" {
  default = 443
}

variable "postgres_port" {
  default = 5432
}

variable "redis_port" {
  default = 6379
}

variable "clamav_port" {
  default = 3310
}

##############################################################
# S3 Bucket name
##############################################################

locals {
  artifact_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.build-artifacts"
  log_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.${lower(var.environment_name)}.logs"
  app_api_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.${lower(var.environment_name)}.app-api-data"
  assets_bucket_name = "${data.aws_caller_identity.current.account_id}-assets"
  s3_logging_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.s3.access-logs"
}

########################
# ClamAV Variables
########################
variable "clamav_desired_capacity" {
  type = "string"
  default = "1"
}

variable "clamav_maximum_capacity" {
  type = "string"
  default = "1"
}

variable "clamav_minimum_capacity" {
  type = "string"
  default = "1"
}

variable "clamav_asg_name" {
  type = "string"
  default = "CCSDEV_clamav_instance_autoscaling"
}

variable "clamav_ami_id" {
  type = "string"
  default = "ami-00bed1ddbf69376d1"
}

variable "clamav_instance_type" {
  type = "string"
  default = "t2.medium"
}

variable "clamav_key_name" {
  type = "string"
  default = "ccs_bastion"
}

variable "clamav_launch_template_name" {
  type = "string"
  default = "CCSDEV_clamav_launch_template"
}

variable "clamav_device_name" {
  type = "string"
  default = "/dev/xvda"
}

variable "clamav_volume_size" {
  type = "string"
  default = "15"
}

variable "clamav_volume_type" {
  type = "string"
  default = "gp2"
}

variable "clamav_name_tag" {
  type = "string"
  default = "CLAM_AV"
}

variable "clamav_internal_ssh_sg_name" {
  type = "string"
  default = "CCSDEV-internal-ssh"
}

variable "clamav_internal_api_sg_name" {
  type = "string"
  default = "CCSDEV-internal-api"
}

variable "clamav_instance_profile_name" {
  type = "string"
  default = "CCSDEV_clamav_instance_profile"
}

variable "clamav_instance_role" {
  type = "string"
  default = "CCSDEV-clamav-instance-role"
}

variable "CCSDEV_clamv_subnet_id" {
  type = "string"
  default = "subnet-09fe3e1109b9a89b6"
}
