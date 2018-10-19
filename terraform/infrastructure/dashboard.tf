##############################################################
#
# CCSDEV Basic Dashboard
#
##############################################################

resource "aws_cloudwatch_dashboard" "CCSDEV-Dashboard" {
  dashboard_name = "CCSDEV-Dashboard"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 18,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ECS", "CPUUtilization", "ServiceName", "cmp", "ClusterName", "${aws_ecs_cluster.CCSDEV_app_cluster.name}", { "period": 60 } ],
                    [ ".", "MemoryUtilization", ".", ".", ".", ".", { "period": 60, "yAxis": "right" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    },
                    "right": {
                        "max": 100,
                        "min": 0
                    }
                },
                "title": "Market Place Service CPU and Memory Utilisation",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 18,
            "width": 18,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${aws_alb.CCSDEV_app_cluster_alb.arn_suffix}", { "period": 60 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "title": "App Cluster Target Response Time",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 48,
            "width": 18,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${aws_alb.CCSDEV_api_cluster_alb.arn_suffix}", { "period": 60 } ]
                ],
                "region": "${var.region}",
                "title": "Api Cluster Target Response Time",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 24,
            "width": 18,
            "height": 9,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${aws_alb.CCSDEV_app_cluster_alb.arn_suffix}", { "period": 60, "stat": "Sum" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "title": "App Cluster Average Requests/Minute",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 54,
            "width": 18,
            "height": 9,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${aws_alb.CCSDEV_api_cluster_alb.arn_suffix}", { "period": 60 } ]
                ],
                "region": "${var.region}",
                "title": "Api Cluster Average Requests/Minute"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 33,
            "width": 18,
            "height": 9,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", "${aws_alb.CCSDEV_app_cluster_alb.arn_suffix}", { "period": 60 } ],
                    [ ".", "HTTPCode_ELB_4XX_Count", ".", ".", { "period": 60 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "title": "App Cluster HTTP 4xx and 5xx errors",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 63,
            "width": 18,
            "height": 9,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", "${aws_alb.CCSDEV_api_cluster_alb.arn_suffix}", { "period": 60 } ],
                    [ ".", "HTTPCode_ELB_4XX_Count", ".", ".", { "period": 60 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "title": "Api Cluster HTTP 4xx and 5xx errors",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 18,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "ccsdev-db", { "period": 60 } ],
                    [ ".", "ReadIOPS", ".", ".", { "yAxis": "right", "period": 60 } ],
                    [ ".", "WriteIOPS", ".", ".", { "yAxis": "right", "period": 60 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "title": "Default Database CPU and IOPS",
                "period": 300,
                "yAxis": {
                    "right": {
                        "min": 0,
                        "max": 100
                    }
                }
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 12,
            "width": 18,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ECS", "CPUUtilization", "ClusterName", "${aws_ecs_cluster.CCSDEV_app_cluster.name}", { "period": 60 } ],
                    [ ".", "MemoryUtilization", ".", ".", { "period": 60, "yAxis": "right" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "title": "App Cluster CPU and Memory Utilisation",
                "period": 300,
                "yAxis": {
                    "left": {
                        "max": 100
                    },
                    "right": {
                        "max": 100
                    }
                }
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 42,
            "width": 18,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ECS", "CPUUtilization", "ClusterName", "${aws_ecs_cluster.CCSDEV_api_cluster.name}", { "period": 60 } ],
                    [ ".", "MemoryUtilization", ".", ".", { "period": 60, "yAxis": "right" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "title": "Api Cluster CPU and Memory Utilisation",
                "period": 300,
                "yAxis": {
                    "left": {
                        "max": 100
                    },
                    "right": {
                        "max": 100
                    }
                }
            }
        }
    ]
}
EOF
}
