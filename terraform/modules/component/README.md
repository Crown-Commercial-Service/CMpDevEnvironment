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
  name = "cmp"

  # Specify the hostname that the component should be hosted at, default to the name if not specified
  hostname = "application"

  # Setting this to true will generate an additional rule for *.domain to this application or container.
  catch_all = false

  # Specify the type of build (This can be the prefix of any buildspec.yml file within the build module directory).
  build_type = "ruby"

  # Specify the github owner related to the source code repo.
  github_owner = "Crown-Commercial-Service"

  # Specify the github repo that holds the source code.
  github_repo = "crown-marketplace"

  # Specify the github branch to build.
  github_branch = "master"

  # Specify the AWS Parameter Store Key name that holds a Personal Access token for Github.
  github_token_alias = "ccs-build_github_token"

  # Specify the name of the AWS ECS Cluster that the container should be deployed to.
  cluster_name = "app_cluster"

  # Enable support for Cognito
  enable_cognito_support = true

  # If enabled the call-back to the Application or API the Cognito will use
  cognito_login_callback = "auth/cognito/callback"

  # Specify the number of component instances that should be launched initially.
  task_count = 1

  # Enables an auto-scaling policy, setting minimum number of container instances
  autoscaling_min_count = 1

  # Enables an auto-scaling policy, setting maximum number of container instances
  autoscaling_max_count = 4

  # Enables test phases in the pipeline
  enable_tests = true

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
* `enable_cognito_support` : If enabled this will generate a Cognito application client definition that allows access to the user pool defined in the infrastructure. It will generate a corresponding environment variable, `COGNITO_CLIENT_ID` containing the client identifier.

You can find any other parameters in [variables.tf](variables.tf).

Check out the [app1 example](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/blob/production/terraform/build/app1/main.tf) for fully-working sample code. 

## What's included in this module?

This module creates an AWS CloudWatch Log Group and also calls into the [`build`](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/tree/production/terraform/modules/build), [`deploy_pipeline`](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/tree/production/terraform/modules/deploy_pipeline), [`ecs_service`](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/tree/production/terraform/modules/ecs_service) and [`routing`](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/tree/production/terraform/modules/routing) modules.
