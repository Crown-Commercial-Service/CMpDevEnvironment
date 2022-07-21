resource "aws_s3_bucket" "db_snapshot_s3" {
  bucket = "${local.db_snapshot_bucket_name}"

  logging {
    target_bucket = "${data.aws_s3_bucket.s3_logging_bucket.id}"
    target_prefix = "Logs/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }
}

data "aws_iam_policy_document" "db_snapshot_s3" {
  statement {
    effect = "Deny"

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    actions = [
      "s3:*",
    ]

    condition {
      test = "Bool"

      values = [
        "false",
      ]

      variable = "aws:SecureTransport"
    }

    resources = [
      "${aws_s3_bucket.db_snapshot_s3.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "db_snapshot_public_access_block" {
  bucket = "${aws_s3_bucket.db_snapshot_s3.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

locals {
  db_snapshot_bucket_name = "${data.aws_caller_identity.current.account_id}-dbsnapshot"
}
