data "aws_caller_identity" "current" {}

data "aws_canonical_user_id" "current_user" {}

locals {
  s3_logging_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.s3.access-logs"
}

resource "aws_s3_bucket" "s3_logging_bucket" {
  bucket = "${local.s3_logging_bucket_name}"

  grant {
    permissions = ["READ_ACP", "WRITE"]
    type        = "Group"
    uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
  }

  grant {
    id          = "${data.aws_canonical_user_id.current_user.id}"
    type        = "CanonicalUser"
    permissions = ["READ_ACP", "WRITE_ACP", "WRITE", "READ"]
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    CCSEnvironment = "Development"
    CCSRole        = "Infrastructure"
    Name           = "CCS Development Access Logs Bucket"
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "s3_logging_bucket_public_access_block" {
  bucket = "${aws_s3_bucket.s3_logging_bucket.id}"

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "secure_transport_policy" {
  statement {
    effect = "Deny"

    principals {
      identifiers = ["*"]
      type = "*"
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
      "${aws_s3_bucket.s3_logging_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "s3_logging_bucket_policy" {
  bucket = "${aws_s3_bucket.s3_logging_bucket.bucket}"
  policy = "${data.aws_iam_policy_document.secure_transport_policy.json}"
}
