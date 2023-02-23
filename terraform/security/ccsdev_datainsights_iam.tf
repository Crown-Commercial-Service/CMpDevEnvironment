##############################################################
#
# CCSDEV DataInsights IAM Configuration
#
# This script defines user/group related DataInsights IAM assets
#
#   Polices
#     CCS_S3_Export_Data_Insights
#   Roles
#   Groups
#     CCS_S3_Export_Data_Insights
#
#   Users
#     data-insights (manual)
#
##############################################################

resource "aws_iam_group" "CCS_S3_Export_Data_Insights" {
  name = "CCS_S3_Export_Data_Insights"
}

resource "aws_iam_policy" "CCS_S3_Export_Data_Insights" {
  name   = "CCS_S3_Export_Data_Insights"
  path   = "/"
  policy = "${data.aws_iam_policy_document.CCS_S3_Export_Data_Insights.json}"
}

data "aws_iam_policy_document" "CCS_S3_Export_Data_Insights" {
  statement {
    sid = "AllowUserToSeeBucketListInTheConsole"

    effect = "Allow"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    sid = "AllowRootFolder"

    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::ccs.825472176441.preview.app-api-data",
    ]

    condition {
      test = "StringEquals"
      variable = "s3:prefix"
      values = [
          "",
          "facilities_management/",
          "facilities_management/data/",
        ]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:delimiter"
      values   = ["/"]
    }
  }
  
  statement {
    sid = "AllowListingOfUserFolder"

    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::ccs.825472176441.preview.app-api-data",
    ]

    condition {
      test = "StringLike"
      variable = "s3:prefix"
      values = [
          "facilities_management/data/exports/*",
        ]
    }
  }

  statement {
    sid = "AllowAllS3ActionsInUserFolder"

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]

    resources = [
      "arn:aws:s3:::ccs.825472176441.preview.app-api-data/facilities_management/data/exports/*",
    ]
  }
}

resource "aws_iam_group_policy_attachment" "CCS_S3_Export_Data_Insights" {
  group      = "${aws_iam_group.CCS_S3_Export_Data_Insights.name}"
  policy_arn = "${aws_iam_policy.CCS_S3_Export_Data_Insights.arn}"
}
