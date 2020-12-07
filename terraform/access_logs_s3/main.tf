data "aws_caller_identity" "current" {}

data "aws_canonical_user_id" "current_user" {}

locals {
  s3_logging_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.${var.environment}.access-logs"
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
    CCSEnvironment = "Sandbox"
    CCSRole        = "Infrastructure"
    Name           = "CCS Sandbox Access Logs Bucket"
  }

  versioning {
    enabled = true
  }
}
