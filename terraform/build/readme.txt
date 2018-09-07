Terraform Scripts for Rebuilding CCS APP infrastructure
=======================================================

These scripts use Terraform from Hashicorp (https://www.terraform.io/) to recreate an app environment / pipeline within AWS. This includes the:
Container Repository
Container Service
Container Task Definition
Subdomain Load-Balancer Domain mappings
AWS CodeBuild project
AWS CodePipeline deployment setup

Using the scripts
-----------------
This assumes the files are checked out from bitbucket, Terraform is already installed and a suitable Amazon AWS account is available.

1/ Ensure there is an environment variable GITHUB_TOKEN that is set to the appropriate personal access token from the ccs-build github account

2/ Execute 'terraform init'

3/ Execute 'terraform apply', review the proposed changes and enter 'yes' to execute the plan.



