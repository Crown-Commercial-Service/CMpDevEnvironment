resource "aws_s3_bucket" "test_logging_bucket" {
  acl    = "log-delivery-write"
  bucket = "${local.s3_logging_bucket_name}"

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

resource "aws_s3_bucket" "ithc_test_bucket_name" {
  bucket = "${local.ithc_test_bucket_name}"

  logging {
    target_bucket = "${aws_s3_bucket.test_logging_bucket.id}"
    target_prefix = "log/"
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