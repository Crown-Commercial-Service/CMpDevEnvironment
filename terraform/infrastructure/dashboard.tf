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
                    [ "AWS/ECS", "MemoryUtilization", "ServiceName", "app1", "ClusterName", "${aws_ecs_cluster.CCSDEV_app_cluster.name}", { "period": 60 } ],
                    [ ".", "CPUUtilization", ".", ".", ".", "." ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "max": 100,
                        "min": 0
                    },
                    "right": {
                        "max": 100,
                        "min": 0
                    }
                },
                "title": "App1 CPU and Memory Utilisation",
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
                    [ "AWS/ECS", "CPUUtilization", "ServiceName", "api1", "ClusterName", "${aws_ecs_cluster.CCSDEV_api_cluster.name}", { "period": 60 } ],
                    [ ".", "MemoryUtilization", ".", ".", ".", ".", { "yAxis": "right" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "max": 100,
                        "min": 0
                    },
                    "right": {
                        "max": 100,
                        "min": 0
                    }
                },
                "title": "Api1 CPU and Memory Utilisation"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 12,
            "width": 18,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${aws_alb.CCSDEV_app_cluster_alb.arn_suffix}", { "period": 60 } ]
                ],
                "region": "${var.region}",
                "title": "App Cluster Target Response Time"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 12,
            "width": 18,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${aws_alb.CCSDEV_api_cluster_alb.arn_suffix}", { "period": 60 } ]
                ],
                "region": "${var.region}",
                "title": "Api Cluster Target Response Time"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 12,
            "width": 18,
            "height": 9,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${aws_alb.CCSDEV_app_cluster_alb.arn_suffix}", { "period": 60 } ]
                ],
                "region": "${var.region}",
                "title": "App Cluster Average Requests/Minute"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 12,
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
            "y": 12,
            "width": 18,
            "height": 9,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", "${aws_alb.CCSDEV_app_cluster_alb.arn_suffix}", { "period": 60 } ],
                    [ ".", "HTTPCode_ELB_4XX_Count", ".", "." ]
                ],
                "region": "${var.region}",
                "title": "App HTTP 4xx and 5xx errors"
            }
        },    
        {
            "type": "metric",
            "x": 0,
            "y": 12,
            "width": 18,
            "height": 9,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", "${aws_alb.CCSDEV_api_cluster_alb.arn_suffix}", { "period": 60 } ],
                    [ ".", "HTTPCode_ELB_4XX_Count", ".", "." ]
                ],
                "region": "${var.region}",
                "title": "Api HTTP 4xx and 5xx errors"
            }
        }    

    ]
}
 EOF
}
