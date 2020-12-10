resource "aws_s3_bucket" "config_bucket_s3" {
  bucket = "${local.config_bucket_name}"

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

data "aws_iam_policy_document" "config_bucket_policy" {
  statement {
    sid     = "AWSConfigBucketPermissionsCheck"
    effect  = "Allow"
    actions = ["s3:GetBucketAcl"]

    principals {
      identifiers = ["config.amazonaws.com"]
      type        = "Service"
    }

    resources = ["${aws_s3_bucket.config_bucket_s3.arn}"]
  }

  statement {
    sid     = "AWSConfigBucketDelivery"
    effect  = "Allow"
    actions = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }

    principals {
      identifiers = ["config.amazonaws.com"]
      type        = "Service"
    }

    resources = ["${aws_s3_bucket.config_bucket_s3.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"]
  }

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
      "${aws_s3_bucket.config_bucket_s3.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "config_bucket_s3" {
  bucket = "${aws_s3_bucket.config_bucket_s3.bucket}"
  policy = "${data.aws_iam_policy_document.config_bucket_policy.json}"
}

locals {
  config_bucket_name = "config-bucket-${data.aws_caller_identity.current.account_id}"
}
