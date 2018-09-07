##############################################################
# Artifact Storage
##############################################################
resource "aws_s3_bucket" "build-artifacts" {
  bucket = "ccsdev-build-artifacts"
  acl    = "private"

  lifecycle_rule {
    enabled = true

    expiration {
      days = 3
    }
  }
}
