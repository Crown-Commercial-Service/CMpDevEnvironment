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
  default = "Development"
}

##############################################################
# Bastion host server settings
##############################################################

variable "bastion_ami" {
  default = "ami-dff017b8"
}

variable "bastion_instance_class" {
  default = "t2.micro"
}

variable "bastion_key_name" {
  default = "ccs_bastion"
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
  default = false
}
##############################################################
# cluster settings - Application
##############################################################

variable "app_cluster_ami" {
   default = "ami-0209769f0c963e791"
}

variable "app_cluster_instance_class" {
  default = "m5.large"
}

variable "app_cluster_instance_count" {
  default = "2"
}

variable "app_cluster_key_name" {
  default = "ccs_cluster"
}

##############################################################
# cluster settings - APIs
##############################################################

variable "api_cluster_ami" {
  default = "ami-0209769f0c963e791"
}

variable "api_cluster_instance_class" {
  default = "m5.large"
}

variable "api_cluster_instance_count" {
  default = "2"
}

variable "api_cluster_key_name" {
  default = "ccs_cluster"
}

##############################################################
# Databases Settings
##############################################################

variable "create_rds_database" {
  default = false
}

variable "db_instance_class" {
  default = "db.t2.medium"
}

variable "db_storage" {
  default = 20
}

variable "db_name" {
  default = "CCSDEV"
}

variable "db_username" {
  default = "ccsdev"
}

variable "db_password" {
  default = "Adm1nDev"
}

##############################################################
# Elastic Search Settings
##############################################################

variable "create_elasticsearch_domain" {
  default = false
}

variable "elasticsearch_domain" {
  default = "ccsdev-search"
}

variable "elasticsearch_instance_class" {
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

##############################################################
# S3 Bucket name
##############################################################

locals {
  artifact_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.build-artifacts"
}
