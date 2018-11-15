##############################################################
# SNS Topics and Events for Notifications
#
# This includea custom police to allow events to post
# to the topic.
#
# For the specified Pipeline success and failure topics
# are created. CloudWatch events are then triggered to
# post information to these topics.
#
##############################################################

##############################################################
# Build Success
##############################################################
resource "aws_sns_topic" "pipeline_success_topic" {

  count = "${var.enable}"

  name = "ccsdev_pipeline_${var.name}_success"

  policy = <<EOF
  {
    "Statement":[
        {
          "Sid":"__default_statement_ID",
          "Effect":"Allow",
          "Principal":{
              "AWS":"*"
          },
          "Action":[
              "SNS:Subscribe",
              "SNS:ListSubscriptionsByTopic",
              "SNS:DeleteTopic",
              "SNS:GetTopicAttributes",
              "SNS:Publish",
              "SNS:RemovePermission",
              "SNS:AddPermission",
              "SNS:Receive",
              "SNS:SetTopicAttributes"
          ],
          "Resource":"arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:ccsdev_pipeline_${var.name}_success",
          "Condition":{
              "StringEquals":{
                "AWS:SourceOwner":"${data.aws_caller_identity.current.account_id}"
              }
          }
        },
        {
          "Sid":"Allow_Publish_Events",
          "Effect":"Allow",
          "Principal":{
              "Service":"events.amazonaws.com"
          },
          "Action":"sns:Publish",
          "Resource":"arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:ccsdev_pipeline_${var.name}_success"
        }
    ]
  }
  EOF
}

resource "aws_cloudwatch_event_rule" "pipeline_success_event" {

  count = "${var.enable}"

  name        = "ccsdev_pipeline_${var.name}_success"
  description = "CCSDEV Build Pipeline ${var.name} Success"

  event_pattern = <<PATTERN
    {
      "source": [
        "aws.codepipeline"
      ],
      "resources": [
          "arn:aws:codepipeline:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.name}"
      ],
      "detail-type": [
        "CodePipeline Pipeline Execution State Change"
      ],
      "detail": {
        "state": [
          "SUCCEEDED"
        ]
      }
    }
PATTERN
}

resource "aws_cloudwatch_event_target" "pipeline_success_target" {

  count = "${var.enable}"

  rule      = "${aws_cloudwatch_event_rule.pipeline_success_event.name}"
  arn       = "${aws_sns_topic.pipeline_success_topic.arn}"

  input_transformer = {
      input_paths = {"state" = "$.detail.state", "pipeline" = "$.detail.pipeline"}
      input_template = <<INPUT_TEMPLATE_EOF
        "The Application/API build: [<pipeline>] <state> building from GitHub: ${var.github_owner}/${var.github_repo}/${var.github_branch}"
      INPUT_TEMPLATE_EOF
  }

}

##############################################################
# Build Failure
##############################################################
resource "aws_sns_topic" "pipeline_failure_topic" {

  count = "${var.enable}"

  name = "ccsdev_pipeline_${var.name}_failure"

  policy = <<EOF
  {
    "Statement":[
        {
          "Sid":"__default_statement_ID",
          "Effect":"Allow",
          "Principal":{
              "AWS":"*"
          },
          "Action":[
              "SNS:Subscribe",
              "SNS:ListSubscriptionsByTopic",
              "SNS:DeleteTopic",
              "SNS:GetTopicAttributes",
              "SNS:Publish",
              "SNS:RemovePermission",
              "SNS:AddPermission",
              "SNS:Receive",
              "SNS:SetTopicAttributes"
          ],
          "Resource":"arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:ccsdev_pipeline_${var.name}_failure",
          "Condition":{
              "StringEquals":{
                "AWS:SourceOwner":"${data.aws_caller_identity.current.account_id}"
              }
          }
        },
        {
          "Sid":"Allow_Publish_Events",
          "Effect":"Allow",
          "Principal":{
              "Service":"events.amazonaws.com"
          },
          "Action":"sns:Publish",
          "Resource":"arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:ccsdev_pipeline_${var.name}_failure"
        }
    ]
  }
  EOF

}

resource "aws_cloudwatch_event_rule" "pipeline_failure_event" {

  count = "${var.enable}"

  name        = "ccsdev_pipeline_${var.name}_failure"
  description = "CCSDEV Build Pipeline ${var.name} Failure"

  event_pattern = <<PATTERN
    {
      "source": [
        "aws.codepipeline"
      ],
      "resources": [
          "arn:aws:codepipeline:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.name}"
      ],
      "detail-type": [
        "CodePipeline Pipeline Execution State Change"
      ],
      "detail": {
        "state": [
          "FAILED"
        ]
      }
    }
PATTERN
}

resource "aws_cloudwatch_event_target" "pipeline_failure_target" {

  count = "${var.enable}"

  rule      = "${aws_cloudwatch_event_rule.pipeline_failure_event.name}"
  arn       = "${aws_sns_topic.pipeline_failure_topic.arn}"

  input_transformer = {
      input_paths = {"state" = "$.detail.state", "pipeline" = "$.detail.pipeline"}
      input_template = <<INPUT_TEMPLATE_EOF
        "The Application/API build: [<pipeline>] <state> building from GitHub: ${var.github_owner}/${var.github_repo}/${var.github_branch}"
      INPUT_TEMPLATE_EOF
  }
}


