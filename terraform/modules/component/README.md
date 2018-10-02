# Component

This folder contains a [Terraform](https://www.terraform.io/) module that represents a Component to be built and deployed as a container.

## How do you use this module?

This folder defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your
code by adding a `module` configuration and setting its `source` parameter to URL of this folder:

```hcl
module "build_pipeline" {
  source = "github.com/Crown-Commercial-Service/CMpDevEnvironment//terraform/modules/component?ref=master"

  # Specify a type for the component (app/api).
  type = "app"

  # Specify a prefix for the component.
  prefix = "ccs"

  # Specify a name for the component.
  name = "app1"

  # Specify the type of build (This can be the prefix of any buildspec.yml file within the build module directory).
  build_type = "docker"

  # Specify the github owner related to the source code repo.
  github_owner = "Crown-Commercial-Service"

  # Specify the github repo that holds the source code.
  github_repo = "CMpExampleApp1"

  # Specify the github branch to build.
  github_branch = "master"

  # Specify the AWS Parameter Store Key name that holds a Personal Access token for Github.
  github_token_alias = "ccs-build_github_token"

  # Specify the name of the AWS ECS Cluster that the container should be deployed to.
  cluster_name = "app_cluster"

  # Specify the number of component instances that should be launched.
  task_count = 1

  # Specify any additional environment variables that should be available to the component at runtime.
  environment = [
    {
      name = "CCS_FEATURE_EG1",
      value = "off"
    } 
  ]

  # Specify a port for the component.
  port = "80"

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

Check out the [app1 example](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/blob/develop/terraform/build/app1/main.tf) for fully-working sample code. 

## What's included in this module?

This module creates an AWS CloudWatch Log Group and also calls into the [`build`](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/tree/develop/terraform/modules/build), [`deploy_pipeline`](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/tree/develop/terraform/modules/deploy_pipeline), [`ecs_service`](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/tree/develop/terraform/modules/ecs_service) and [`routing`](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/tree/develop/terraform/modules/routing) modules.
