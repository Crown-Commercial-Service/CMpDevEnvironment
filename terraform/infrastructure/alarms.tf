##############################################################
#
# CCSDEV Alarms
#
# Alarms only defined if var.create_cloudwatch_alarms is true
#
# Defines:
#   SNS Topic to which alarm notifications are sent
#   Alarms:
#       App Cluster CPU usage >50% for 1 minute
#       App Cluster response time >0.5s for 1 minute
#       App ALB  50x errors average > 2 for 1 minute
#       Database CPU usage > 50% for 1 minutes
#
##############################################################

resource "aws_sns_topic" "ccsdev_alarm_topic" {

  count = "${var.create_cloudwatch_alarms}"

  name = "ccsdev_${var.environment_name}_alarm"

  policy = <<EOF
  {
    "Version": "2008-10-17",
    "Statement":[
        {
          "Sid":"Allow_Access",
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
          "Resource":"arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:ccsdev_${var.environment_name}_alarm",
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
          "Resource":"arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:ccsdev_${var.environment_name}_alarm"
        }
    ]
  }
  EOF

}

########################################################
# Alaram:
#  App Cluster CPU usage >50% for 1 minute
########################################################
resource "aws_cloudwatch_metric_alarm" "service_app_cluster_cpu_high" {

  count = "${var.create_cloudwatch_alarms}"

  alarm_name          = "${var.environment_name}-APP-Cluster-CPU-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"
  treat_missing_data  = "notBreaching"

  dimensions {
    ClusterName = "${aws_ecs_cluster.CCSDEV_app_cluster.name}"
  }

  alarm_actions = ["${aws_sns_topic.ccsdev_alarm_topic.arn}"]
}

########################################################
# Alaram:
#  App Cluster response time >0.5s for 1 minute
########################################################
resource "aws_cloudwatch_metric_alarm" "service_app_cluster_resp_time_high" {

  count = "${var.create_cloudwatch_alarms}"

  alarm_name          = "${var.environment_name}-APP-Cluster-Response-Time-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0.5"
  treat_missing_data  = "notBreaching"

  dimensions {
    LoadBalancer = "${aws_alb.CCSDEV_app_cluster_alb.arn_suffix}"
  }

  alarm_actions = ["${aws_sns_topic.ccsdev_alarm_topic.arn}"]
}

########################################################
# Alaram:
#  App ALB  50x errors average > 2 for 1 minute
########################################################
resource "aws_cloudwatch_metric_alarm" "service_app_cluster_50x_high" {

  count = "${var.create_cloudwatch_alarms}"

  alarm_name          = "${var.environment_name}-APP-Cluster-High-50x-Errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "2"
  treat_missing_data  = "notBreaching"

  dimensions {
    LoadBalancer = "${aws_alb.CCSDEV_app_cluster_alb.arn_suffix}"
  }

  alarm_actions = ["${aws_sns_topic.ccsdev_alarm_topic.arn}"]
}


########################################################
# Alaram:
#  Database CPU usage > 50% for 1 minutes
########################################################
resource "aws_cloudwatch_metric_alarm" "service_default_db_cpu_high" {

  count = "${var.create_cloudwatch_alarms}"

  alarm_name          = "${var.environment_name}-Default-DB-CPU-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"
  treat_missing_data  = "notBreaching"

  dimensions {
    DBInstanceIdentifier = "${aws_db_instance.ccsdev_default_db.id}"
  }

  alarm_actions = ["${aws_sns_topic.ccsdev_alarm_topic.arn}"]
}
