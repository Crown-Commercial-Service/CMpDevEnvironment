# Test Deploy Pipeline

This folder contains a [Terraform](https://www.terraform.io/) module to deploy an [AWS CodePipeline](https://aws.amazon.com/codepipeline/) project that utilises existing [AWS CodeBuild](https://aws.amazon.com/codebuild/) projects to test and deploy the resultant containers into [AWS ECS](https://aws.amazon.com/ecs/).

## How do you use this module?

This folder defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your
code by adding a `module` configuration and setting its `source` parameter to URL of this folder:

```hcl
module "deploy_pipeline" {
  source = "github.com/Crown-Commercial-Service/CMpDevEnvironment//terraform/modules/deploy_pipeline?ref=master"

  # Specify a name for the artifact being built.
  artifact_name = "app1"

  # The ARN of the AWS Identity and Access Management (IAM) role that enables AWS CodePipeline to interact with dependent AWS services on behalf of the AWS account.
  service_role_arn = "${data.aws_iam_role.codepipeline_service_role.arn}"

  # Specify the S3 bucket name that is used to store pipeline stage artifacts.
  artifact_bucket_name = "artifact_bucket"

  # Specify the github owner related to the source code repo.
  github_owner = "Crown-Commercial-Service"

  # Specify the github repo that holds the source code.
  github_repo = "CMpDevEnvironment"

  # Specify the github branch to build.
  github_branch = "master"

  # Specify the AWS Parameter Store Key name that holds a Personal Access token for Github.
  github_token_alias = "build_github_token"

  # Specify the name of the AWS CodeBuild project to use for the build stage of the pipeline (this could be an output from a previously declared build module).
  build_project_name = "${module.build.project_name}"

  # Specify the name of the AWS ECS Cluster that the container should be deployed to.
  deploy_cluster_name = "deploy_cluster"

  # Specify the name of the AWS ECS Service that the container should be deployed to.
  deploy_service_name = "deploy_service"

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

Also see [AWS CodePipeline Documentation](https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html) for additional information

## What's included in this module?

This module creates an AWS CodePipeline project.
