resource "aws_s3_bucket" "ithc_test_bucket_name" {
  bucket = "${local.ithc_test_bucket_name}"

  versioning {
    enabled = true
  }
}