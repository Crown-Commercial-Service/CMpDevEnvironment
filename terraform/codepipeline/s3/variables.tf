variable "acl_policy" {
  default = "private"
}

variable "aws_kms_alias" {
  default = "alias/aws/s3"
}

variable "region" {
  default = "eu-west-2"
}

data "aws_caller_identity" "current" {}

locals {
  s3_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.cmpterraformpipeline.tfplan"
}
