# ECS Service

This folder contains a [Terraform](https://www.terraform.io/) module to create an [AWS ECS](https://aws.amazon.com/ecs/) Service that will host one or more containers that represent an API or Application.

## How do you use this module?

This folder defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your
code by adding a `module` configuration and setting its `source` parameter to URL of this folder:

```hcl
module "service" {
  source = "github.com/Crown-Commercial-Service/CMpDevEnvironment//terraform/modules/ecs_service?ref=master"

  # Specify a name for the Service / Task Definition.
  task_name = "app1"

  # Specify the number of service instances that should be launched.
  task_count = "1"

  # Specify an environment map (additional variables that the service may need) that will be used by the Task Definition.
  task_environment = [
      {
        name = "CCS_APP_BASE_URL",
        value = "example.com"
      },
      {
        name = "CCS_APP_PROTOCOL",
        value = "http"
      }
  ]

  # Specify a name for an existing AWS Cloudwatch Log Group to use for logging.
  log_group = "app1_log_group"

  # Specify the name of the AWS ECS Cluster that Service should be created within.
  cluster_name = "app_cluster"

  # Specify the container image to use for the Service. This should be fully-qualified, including the registry.
  image = "app_image"

  # Specify the ARN of the AWS Load Balancer Target Group that the any task within the Service should become a member of.
  target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-targets/73e2d6bc24d8a067"

  # ... See variables.tf for any other parameters you may define
}
```

Note the following parameters:

* `source`: Use this parameter to specify the URL of the build module. The double slash (`//`) is intentional 
  and required. Terraform uses it to specify subfolders within a Git repo (see [module 
  sources](https://www.terraform.io/docs/modules/sources.html)). The `ref` parameter specifies a specific Git tag in 
  this repo. That way, instead of using the latest version of this module from the `master` branch, which 
  will change every time you run Terraform, you're using a fixed version of the repo.

You can find any other parameters in [variables.tf](variables.tf).

Check out the [component module](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/blob/develop/terraform/modules/component/main.tf) for fully-working sample code. 

Also see [AWS ECS Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html) for additional information

## What's included in this module?

This module creates an AWS ECS Service and associated Task Definition.
