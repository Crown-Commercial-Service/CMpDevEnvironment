# Crown Commercial AWS Environment #

## Phase 2.2 Update ##

Version 1.

## DRAFT #

## Rowe IT ##

## October 2018 ##

---

# Table of Contents #

- [CCSDEV AWS Environment](#ccsdev-aws-environment)
- [Updating CCSDEV on an existing Account](#update-ccsdev-on-an-exiating-aws-account)
   - [Assumptions](Assumptions)
   - [Updating scripts from Github](#updating-scripts-from-github)
   - [Updating Terraform shared state configuration](#updating-terraform-shared-state-configuration)
   - [Updating IAM Groups, polices etc](#updating-iam-groups,-polices-etc)
   - [Updating Infrastructure](#updating-infrastructure)
   - [Updating build pipelines](#updating-build-pipelines)

---

# CCSDEV AWS Environment #

The environment provides two AWS Elastic Container Service (ECS) clusters within a Virtual Private
Cloud (VPC), one for `applications` and the other for `apis`. Load balancers are created to access
deployed containers within the clusters. Example application and apis are provided along with
corresponding AWS CodePipeline/Codebuild definitions.

Example instances of an RDS Postgres databases and Elastic Search instances are created.

All of the required AWS assets are created using Terraform scripts except for SSH ‘key pairs’ and a
public hosted zone with the Route 53 DNS service.

> NOTE: This version makes use of Terraform ‘shared state’ that is stored in an S3 bucket,
concurrent access is controlled using a Dynamo DB table^1. This allows the scripts to be
executed from different systems and with different AWS users. This does introduce
some additional complexity. See https://www.terraform.io/docs/backends/types/s3.html

This document explains how to execute these scripts on a new AWS account. Some familiarity with
AWS and Git is assumed.

Several GitHub repositories are involved, each repository contains its own summary and some
specific instructions.

`CMpDevEnvironment` : 
This contains all the Terraform scripts used for building the AWS Infrastructure and the build
pipelines for the example applications. It also contains definitions of several AWS IAM
security groups and policies.

`CMpExampleNPMModule` :
This contains an example NPM module that is referenced by the corresponding build/npm
example pipeline.

`CMpExampleApi1` :
This contains an example api implemented using Java and Springboot. It is referenced by
the corresponding build/api1 example pipeline.

`CMpExampleApp1` : 
This contains an example application implemented using nodeJS and Express. It is
referenced by the corresponding build/app1 example pipeline. This example project uses the
example NPM module and the GOV UK frontend toolkit.

`CMpExampleApi2` : 
This contains an example api implemented using Python and Flask. It is referenced by the
corresponding build/api2 example pipeline.

`CMpExampleApp2` : 
This contains an example application implemented using Ruby on Rails. It is referenced by
the corresponding build/app2 example pipeline. This example project uses the example
NPM module and the GOV UK frontend toolkit.

`CMpDevBuildImage_Ruby` : 
This contains a Dockerfile for creating a new build image that can be used by AWS Codebuild. This may be required when AWS to not provide a suitable build environment. For example, at present Ruby 2.5.3 is not supported by AWS.


# Updating CCSDEV on an existing AWS Account #
It is possible to update the environment wih incremental changes without re-creating the whole infrastructure. Depending on the changes certain part of the infrastructure may be destroyed and re-created. The Terraform 'plan' should be inspected to ensure there are no unexpected changes.

> Note: If the AWS Cognito user pool is deleted and then re-created all existing registered users will be removed. Most changes, for example, password policies or enabling/disabling user self-registration will not cause this.

The general approach to an update is:
- Update the local Git repository from Github
- Work through the scripts in the order bootstrap, security, infrastructure, build pipelines
    - Perform a Terraform init followed by an apply.
- Some scripts may need to be executed multiple time if there are certain permissions or policy changes.

## Assumptions ##

- You have access to an AWS account and access to the root credentials or an IAM user
that is a member of all the CMp environment defined IAM groups.
- There is a fully working CMp environment defined in the account with:
    - A suitable sub-domain already delegated to Route 53
    - A `auto.tfvars` file defining any IP restrictions and the sub-domain name
- Git installed.
- Terraform is installed (https://www.terraform.io/).
- The AWS CLI (https://aws.amazon.com/cli/) is useful but not required.
- To build and publish the example npm modules you will need an account and access token
for npm
- The CCSDEV environment repository is cloned from github at(https://github.com/Crown-Commercial-Service/CMpDevEnvironment). 
- The 'master' branch of this repository is checked out.
- Thw AWS CLI or Terraform environment variables allows access to the AWS account are defined.
- All EC2 Parameter store settings required by any applications or APIs are present.

## Updating scripts from Github ##
The latest Terraform scripts need to be obtained from Github and the existing checkout updated with these scripts.

1. Open a command prompt in the existing `CmpDevEnvironment` folder.
2. Run `git checkout master`.
3. Run `git pull origin master`.

## Updating Terraform shared state configuration ##

This uses the Terraform scripts in `terraform/bootstrap`.

These scripts will perform three different functions:

1. Ensure that the AWS user corresponding to the access keys used is given privileges to create
    the S3 and Dynamo DB table.
2. Create the required S3 buckets and Dynamo DM table.
3. Initialise the Terraform backend configuration in the current git checkout.

To update perform the following steps:

1. Ensure the AWS access keys are configured as described previously.
2. Ensure the command prompt is open in the `bootstrap` directory.
3. Run `terraform init` to install and configure the required providers.
4. Run `terraform apply`.
5. Enter `yes` when prompted.
6. A error indicating that the S3 bucket already exists will be displayed. This can be ignored.


## Updating IAM Groups, polices etc ##

This uses the Terraform scripts in `terraform/security`.

It will create, update or deleted IAM user groups and policy definitions. The AWS user corresponding to the
access keys used will be automatically added to all of resulting groups.

1. Ensure the AWS access keys are configured as described previously.
2. Ensure the command prompt is open in the `security` directory.
3. Run `terraform init` to install and configure the required providers.
4. Run `terraform apply`.
5. Enter `yes` when prompted.

Your IAM user, `sysadmin` is now capable of administering all aspects of the CCSDEV
environment on AWS. It can take a few minutes for these changes to take effect. So, a short pause
before proceeding is recommended.

## Updating Infrastructure ##

This uses the Terraform scripts in terraform/infrastructure.

You should already have a file ending with `.auto.tfvars` in this directory.

> Note that this file should not be stored in a public GitHub repository. The latest versions for various environments are available in the `CMpDevEnvironment_Private` private GitHub repository.

1. Ensure the AWS access keys are configured as described previously.
2. Ensure the command prompt is open in the `infrastructure` directory.
3. Run `terraform init` to install and configure the required providers.
4. Run `terraform apply`.
5. Enter `yes` when prompted.
6. The infrastructure will now be updated. This can take a while, particularly the RDS and
Elastic Search instances are recreated.

> Note: The intention is that the RDS and Elastic search instances can only be accessed from
within the private VPC subnets, thus the API cluster only. However, to assist with the
early development sprints they are currently available from within the public subnets.

## Updating build pipelines ##

This uses the Terraform scripts in `terraform/build/{app-or-api}`.

The actual applications and APIs to update will depend on those currently deployed. The process described below assume it is already deployed and just needs updating.

> Note : It is possible that some applications or APIs may require additional steps that will be documented by the developers. For example the `crown-marketplace` application requires a number of environment variables.

The contents of the application or APIs `main.tf` file may need to be reviewed if creating a pipeline for a branch other than `master`.

1. Ensure the AWS access keys are configured as described previously.
2. Ensure the GitHub token is stored in the parameter store.
3. Ensure the command prompt is open in the `build/{app-or-api}` directory.
4. Run `terraform init` to install and configure the required providers.
5. Run `terraform apply`.
6. Enter `yes` when prompted.
7. The example `app1` build pipe line will now be created. This can take a while.

This will result in a build pipe line being updated.



