# Build

This folder contains a [Terraform](https://www.terraform.io/) module to deploy an [AWS CodeBuild](https://aws.amazon.com/codebuild/) project for an API or Application.

## How do you use this module?

This folder defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your
code by adding a `module` configuration and setting its `source` parameter to URL of this folder:

```hcl
module "build" {
  source = "github.com/Crown-Commercial-Service/CMpDevEnvironment//terraform/modules/build?ref=master"

  # Specify a prefix for the artifact being built.
  artifact_prefix = "ccs"

  # Specify a name for the artifact being built.
  artifact_name = "app1"

  # Specify the github owner related to the source code repo.
  github_owner = "Crown-Commercial-Service"

  # Specify the github repo that holds the source code.
  github_repo = "CMpDevEnvironment"

  # Specify the github branch to build.
  github_branch = "master"

  # Specify the type of build (This can be the prefix of any buildspec.yml file within the module directory).
  build_type = "docker"

  # The ARN of the AWS Identity and Access Management (IAM) role that enables AWS CodeBuild to interact with dependent AWS services on behalf of the AWS account.
  service_role_arn = "${data.aws_iam_role.codebuild_service_role.arn}"

  # The ID of the VPC that AWS CodeBuild will access.
  vpc_id = "${data.aws_vpc.build_vpc.id}"

  # A list of one or more subnet IDs in the VPC.
  subnet_ids = ["${data.aws_subnet.build_subnet.id}"]

  # A list of one or more security groups IDs in the VPC.
  security_group_ids = ["${data.aws_security_group.build_security_group.id}"]

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

Check out the [npm1 example](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/blob/develop/terraform/build/npm1/main.tf) for fully-working sample code. 

Also see [AWS CodeBuild Documentation](https://docs.aws.amazon.com/codebuild/latest/userguide/welcome.html) for additional information

## What's included in this module?

This module creates an AWS CodeBuild project and an AWS ECR Repository.
