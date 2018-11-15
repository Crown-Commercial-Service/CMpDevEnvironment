# Pipeline Events

This folder contains a [Terraform](https://www.terraform.io/) module to create infrastructure associated with collecting build pipeline events and posting these to Simple Notification Service (SNS) topics. This allows then allows email addresses to be subscribed to these topics.

## How do you use this module?

This folder defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your
code by adding a `module` configuration and setting its `source` parameter to URL of this folder:

```hcl
module "pipeline_events" {
  source = "github.com/Crown-Commercial-Service/CMpDevEnvironment//terraform/modules/pipeline_events?ref=master"

  # Set to true to enable creation of the various AWS assets.
  enable = true

  # Specify the name of the build AWS CodePipeline
  name = "app1-pipeline"

  # Specify the github owner related to the source code repo.
  github_owner = "Crown-Commercial-Service"

  # Specify the github repo that holds the source code.
  github_repo = "crown-marketplace"

  # Specify the github branch to build.
  github_branch = "master"

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

Check out the [deploy-pipeline module](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/blob/develop/terraform/modules/deploy-pipeline/main.tf) for fully-working sample code. 

## What's included in this module?

This module creates two `SNS topics` based on the pipeline name. These have the suffix `'_success'` and `'_failure'`. `CloudWatch events` are configured to post to these topics when pipeline `SUCCEEDED` and `FAILED` state changes occur.  
