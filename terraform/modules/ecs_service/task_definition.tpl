[
  {
    "name": "${name}",
    "image": "${image}",
    "cpu": 10,
    "memory": ${memory}
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 0
      }
    ],
    "environment": ${environment},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
          "awslogs-group": "${log_group}",
          "awslogs-region": "eu-west-2",
          "awslogs-stream-prefix": "${name}"
      }
    }
  }
]  