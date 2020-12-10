##############################################################
# Artifact Storage
##############################################################
data "aws_s3_bucket" "s3_logging_bucket" {
  bucket = "${local.s3_logging_bucket_name}"
}

resource "aws_s3_bucket" "build-artifacts" {
  bucket = "${local.artifact_bucket_name}"
  acl    = "private"

  lifecycle_rule {
    enabled = true

    expiration {
      days = 3
    }
  }

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

  tags {
    Name = "CCSDEV Build Artifacts bucket"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }

  versioning {
    enabled = true
  }
}

data "aws_iam_policy_document" "build_artifacts_policy" {
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
      "${aws_s3_bucket.build-artifacts.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "attach_secure_transport_policy_to_build_artifacts_s3" {
  bucket = "${aws_s3_bucket.build-artifacts.bucket}"
  policy = "${data.aws_iam_policy_document.build_artifacts_policy.json}"
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
# Application/API Storage
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
# Asset Storage
##############################################################
resource "aws_iam_policy" "CCSDEV_assets_bucket_policy" {
  name   = "CCSDEV_assets_bucket_policy"
  path   = "/"
  policy = "${data.aws_iam_policy_document.CCSDEV_assets_bucket_policy_doc.json}"
}

resource "aws_iam_group_policy_attachment" "dev-api-assets-bucket-policy-attachment" {
  group      = "CCS_Developer_API_Access"
  policy_arn = "${aws_iam_policy.CCSDEV_assets_bucket_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "task-role-assets-bucket-policy-attachment" {
  role       = "CCSDEV-task-role"
  policy_arn = "${aws_iam_policy.CCSDEV_assets_bucket_policy.arn}"
}

data "aws_iam_policy_document" "CCSDEV_assets_bucket_policy_doc" {

  statement {
    effect = "Allow",
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "${aws_s3_bucket.assets-bucket.arn}"
    ]
  }

  statement {
    effect = "Allow",
    actions = [
      "s3:PutObject*",
    ]
    resources = [
      "${aws_s3_bucket.assets-bucket.arn}/*"
    ]
  }

}

resource "aws_s3_bucket" "assets-bucket" {
  bucket = "${local.assets_bucket_name}"
  
   acl    = "public-read"
  #grant {
  #  type        = "Group"
  #  uri         = "http://acs.amazonaws.com/groups/global/AllUsers"
  #  permissions = ["READ_ACP"]
  #}

  tags {
    Name = "CCSDEV Application/assets bucket"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}


##############################################################
# Add custom policy to CCS_Developer_API_Access group and
# the container task role to
# allow access to this S3 bucket and the shared post-code bucket
##############################################################

resource "aws_iam_group_policy_attachment" "app-api-data-bucket-access" {
  group      = "CCS_Developer_API_Access"
  policy_arn = "${aws_iam_policy.CCSDEV_app_api_data_bucket_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "CCSDEV_task_role_attachment" {
  role       = "CCSDEV-task-role"
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

resource "aws_iam_group_policy_attachment" "postcode-data-bucket-access" {
  group      = "CCS_Developer_API_Access"
  policy_arn = "${aws_iam_policy.CCSDEV_postcode_data_bucket_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "CCSDEV_task_role_attachment_postcode" {
  role       = "CCSDEV-task-role"
  policy_arn = "${aws_iam_policy.CCSDEV_postcode_data_bucket_policy.arn}"
}

resource "aws_iam_policy" "CCSDEV_postcode_data_bucket_policy" {
  name   = "CCS_shared_postcode_data_bucket_policy"
  path   = "/"
  policy = "${data.aws_iam_policy_document.CCSDEV_postcode_data_bucket_policy_doc.json}"
}

data "aws_iam_policy_document" "CCSDEV_postcode_data_bucket_policy_doc" {

  statement {

    effect = "Allow",
    actions = [
                "s3:*",
    ]

    resources = [
                "${var.shared_postcode_data_bucket}",
                "${var.shared_postcode_data_bucket}/*"
    ]
  }

}


