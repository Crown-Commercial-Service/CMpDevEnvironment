##############################################################
#
# CCSDEV GitHub Deployment IAM Configuration
#
# This script defines user/group related GitHub Deploy IAM assets
#
#   Polices
#     CCS_StartPipeline
#   Roles
#   Groups
#     CCS_StartPipeline
#   Users
#     pipeline_github
#
##############################################################

resource "aws_iam_group" "CCS_StartPipeline" {
  name = "CCS_StartPipeline"
}

resource "aws_iam_policy" "CCS_StartPipeline" {
  name   = "CCS_StartPipeline"
  path   = "/"
  policy = "${data.aws_iam_policy_document.CCS_StartPipeline.json}"
}

data "aws_iam_policy_document" "CCS_StartPipeline" {
  statement {
    effect = "Allow"

    actions = [
      "codepipeline:StartPipelineExecution"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_group_policy_attachment" "CCS_StartPipeline" {
  group      = "${aws_iam_group.CCS_StartPipeline.name}"
  policy_arn = "${aws_iam_policy.CCS_StartPipeline.arn}"
}

resource "aws_iam_user" "pipeline_github" {
    name = "pipeline_github"
}

resource "aws_iam_user_group_membership" "pipeline_github" {
  user = "${aws_iam_user.pipeline_github.name}"
  groups = [
    "${aws_iam_group.CCS_StartPipeline.name}"
  ]
}
