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
                    [ "AWS/ECS", "MemoryUtilization", "ServiceName", "cmp", "ClusterName", "CCSDEV_app_cluster", { "period": 60 } ],
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
                "title": "Marketplace App CPU and Memory Utilisation",
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
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "app/CCSDEV-app-cluster-alb/36f722265fe8e360", { "period": 60 } ]
                ],
                "region": "${var.region}",
                "title": "App Cluster Target Response Time"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 24,
            "width": 18,
            "height": 9,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "app/CCSDEV-app-cluster-alb/36f722265fe8e360", { "period": 60 } ]
                ],
                "region": "${var.region}",
                "title": "App Cluster Average Requests/Minute"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 33,
            "width": 18,
            "height": 9,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", "app/CCSDEV-app-cluster-alb/36f722265fe8e360", { "period": 60 } ],
                    [ ".", "HTTPCode_ELB_4XX_Count", ".", "." ]
                ],
                "region": "${var.region}",
                "title": "App HTTP 4xx and 5xx errors"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 42,
            "width": 18,
            "height": 9,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", "app/CCSDEV-api-cluster-alb/4d9d8812392f9c65", { "period": 60 } ],
                    [ ".", "HTTPCode_ELB_4XX_Count", ".", "." ]
                ],
                "region": "${var.region}",
                "title": "Api HTTP 4xx and 5xx errors"
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
                    [ "AWS/RDS", "WriteIOPS", "DBInstanceIdentifier", "ccsdev-db" ],
                    [ ".", "ReadIOPS", ".", "." ]
                ],
                "region": "${var.region}",
                "title": "Default Database IOPS"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 18,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "ccsdev-db" ]
                ],
                "region": "${var.region}",
                "title": "Default Database CPU"
            }
        }
    ]
}
EOF
}
