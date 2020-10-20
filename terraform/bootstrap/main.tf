terraform {
  required_version = "~> 0.11"
}

data "aws_caller_identity" "current" {}

locals {
    bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.tfstate"
}

resource "aws_iam_user_policy_attachment" "bootstrap-dynamodb-attach" {
    user       = "${basename(data.aws_caller_identity.current.arn)}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_user_policy_attachment" "bootstrap-s3-attach" {
    user       = "${basename(data.aws_caller_identity.current.arn)}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${local.bucket_name}"

  versioning {
    enabled = true
  }

  lifecycle {
    ignore_changes = [
        "bucket",
        ]
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform_state_lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  depends_on = [
      "aws_iam_user_policy_attachment.bootstrap-dynamodb-attach",
      "aws_iam_user_policy_attachment.bootstrap-s3-attach"
    ]
}

module "security_backend" {
    source    = "./backend"

    bucket    = "${local.bucket_name}"
    component = "security"
    region    = "${var.region}"
    path      = "${path.module}"
}

module "infrastructure_backend" {
    source    = "./backend"

    bucket    = "${local.bucket_name}"
    component = "infrastructure"
    region    = "${var.region}"
    path      = "${path.module}"
}

module "api1_backend" {
    source    = "./backend"

    bucket    = "${local.bucket_name}"
    component = "build/api1"
    region    = "${var.region}"
    path      = "${path.module}"
}

module "api2_backend" {
    source    = "./backend"

    bucket    = "${local.bucket_name}"
    component = "build/api2"
    region    = "${var.region}"
    path      = "${path.module}"
}

module "app1_backend" {
    source    = "./backend"

    bucket    = "${local.bucket_name}"
    component = "build/app1"
    region    = "${var.region}"
    path      = "${path.module}"
}

module "app2_backend" {
    source    = "./backend"

    bucket    = "${local.bucket_name}"
    component = "build/app2"
    region    = "${var.region}"
    path      = "${path.module}"
}

module "npm1_backend" {
    source    = "./backend"

    bucket    = "${local.bucket_name}"
    component = "build/npm1"
    region    = "${var.region}"
    path      = "${path.module}"
}

module "cmp_backend" {
    source    = "./backend"

    bucket    = "${local.bucket_name}"
    component = "build/crown-marketplace"
    region    = "${var.region}"
    path      = "${path.module}"
}

module "cmp_legacy_backend" {
    source    = "./backend"

    bucket    = "${local.bucket_name}"
    component = "build/crown-marketplace-legacy"
    region    = "${var.region}"
    path      = "${path.module}"
}

module "cmp_upload_backend" {
    source    = "./backend"

    bucket    = "${local.bucket_name}"
    component = "build/crown-marketplace-upload"
    region    = "${var.region}"
    path      = "${path.module}"
}

module "cmp_maintenance_backend" {
    source    = "./backend"

    bucket    = "${local.bucket_name}"
    component = "build/cmp-maintenance"
    region    = "${var.region}"
    path      = "${path.module}"
}

module "cmp_supply_teacher_upload_backend" {
    source    = "./backend"

    bucket    = "${local.bucket_name}"
    component = "build/upload-supply-teacher-data"
    region    = "${var.region}"
    path      = "${path.module}"
}

module "cmp_sidekiq_backend" {
    source    = "./backend"

    bucket    = "${local.bucket_name}"
    component = "build/crown-marketplace-sidekiq"
    region    = "${var.region}"
    path      = "${path.module}"
}

module "image-ruby_backend" {
    source    = "./backend"

    bucket    = "${local.bucket_name}"
    component = "build/image-ruby"
    region    = "${var.region}"
    path      = "${path.module}"
}

module "ssm-config_backend" {
    source    = "./backend"

    bucket    = "${local.bucket_name}"
    component = "ssm-config"
    region    = "${var.region}"
    path      = "${path.module}"
}
