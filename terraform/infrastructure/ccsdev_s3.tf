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

##############################################################
# Appliaction/API Storage
##############################################################
resource "aws_s3_bucket" "app-api-data-bucket" {
  bucket = "${local.app_api_bucket_name}"
  acl    = "private"

  tags {
    Name = "CCSDEV Application/API data bucket"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

##############################################################
# Add custom policy to CCS_Developer_API_Access group to
# allow access to this S3 bucket.
##############################################################

resource "aws_iam_group_policy_attachment" "app-api-data-bucket-access" {
  group      = "CCS_Developer_API_Access"
  policy_arn = "${aws_iam_policy.CCSDEV_app_api_data_bucket_policy.arn}"
}

resource "aws_iam_policy" "CCSDEV_app_api_data_bucket_policy" {
  name   = "CCSDEV_app_api_data_bucket_policy"
  path   = "/"
  policy = "${data.aws_iam_policy_document.CCSDEV_app_api_data_bucket_policy_doc.json}"
}

data "aws_iam_policy_document" "CCSDEV_app_api_data_bucket_policy_doc" {

  statement {

    effect = "Allow",
    actions = [
                "s3:*",
    ]

    resources = [
                "${aws_s3_bucket.app-api-data-bucket.arn}",
                "${aws_s3_bucket.app-api-data-bucket.arn}/*"
    ]
  }

}
