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

  tags {
    Name = "CCSDEV Build Artifacts bucket"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

##############################################################
# Log Storage
##############################################################
data "aws_iam_policy_document" "log_policy_document" {
  statement {

    principals = {
      type = "AWS"
      identifiers = ["652711504416"] # eu-west-2 ALB ID
    }

    actions = [
      "s3:PutObject",
    ]

    resources = ["arn:aws:s3:::${local.log_bucket_name}/*"]
  }
}

# resource "aws_s3_bucket_policy" "logs_policy" {
#   bucket = "${aws_s3_bucket.logs.id}"
#   policy = "${aws}"
# }

resource "aws_s3_bucket" "logs" {
  bucket = "${local.log_bucket_name}"
  acl    = "private"

  lifecycle_rule {
    enabled = true

    expiration {
      days = 5
    }
  }

  lifecycle_rule {
    enabled = true
    prefix = "alb/" # Shorter rule for ALB logs

    expiration {
      days = 1
    }
  }

  policy = "${data.aws_iam_policy_document.log_policy_document.json}"

  tags {
    Name = "CCSDEV Logs bucket"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}
