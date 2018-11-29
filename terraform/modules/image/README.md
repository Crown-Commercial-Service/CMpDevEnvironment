# Image

This folder contains a [Terraform](https://www.terraform.io/) module that represents a container image to be built and used in subsequent build projects.

## How do you use this module?

This folder defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your
code by adding a `module` configuration and setting its `source` parameter to URL of this folder:

```hcl
module "image" {
  source = "github.com/Crown-Commercial-Service/CMpDevEnvironment//terraform/modules/image?ref=master"

  # Specify a prefix for the image.
  prefix = "ccs"

  # Specify a name for the image.
  name = "ruby"

  # Specify the github owner related to the source code repo.
  github_owner = "Crown-Commercial-Service"

  # Specify the github repo that holds the source code.
  github_repo = "CMpDevBuildImage_Ruby"

  # Specify the github branch to build.
  github_branch = "master"

  # Specify the AWS Parameter Store Key name that holds a Personal Access token for Github.
  github_token_alias = "ccs-build_github_token"

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

Check out the [ruby example](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/blob/production/terraform/build/image-ruby/main.tf) for fully-working sample code. 

## What's included in this module?

This module creates an AWS CodeBuild project and an AWS ECR Repository.
