data "aws_kms_key" "s3_kms_key" {
  key_id = "${var.aws_kms_alias}"
}

resource "aws_s3_bucket" "cmp_terraform_tfplan_s3_bucket" {
  acl    = "${var.acl_policy}"
  bucket = "${local.s3_bucket_name}"

  tags = {
    Name        = "${local.s3_bucket_name}"
  }

  versioning {
    enabled     = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${data.aws_kms_key.s3_kms_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
