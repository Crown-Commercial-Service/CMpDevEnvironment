##############################################################
# Artifact Storage
##############################################################
resource "aws_s3_bucket" "build-artifacts" {
  bucket = "${local.artifact_bucket_name}"
  acl    = "private"

  lifecycle_rule {
    enabled = true

    expiration {
      days = 3
    }
  }
}
