# Crown Commercial Environment (Development)

This project contains [Terraform](https://www.terraform.io/) scripts that are used to generate a container hosting environment in AWS. This environment in the eu-wst-2 region.

This environment allows the deployment of externally accessible *application* containers and private *api* containers. Example build pipe lines for an application, api and NPM module are also provided.

The available scripts are divided into three areas: security, infrastructure and build pipelines. When creating a new environment scripts will need to be initially executed in that order.

All of the scripts will require `terraform init` to be executed in the correct directory.

---

## IAM Security
`/terraform/security`

The security scripts generate a number of IAM user groups and policies documents. They do not create any actual users.

The following groups are created:

- CCS_System_Administration
- CCS_User_Administration
- CCS_Infrastructure_Administration
- CCS_Application_Developer
- CCS_API_Developer
- CCS_Code_Build_Pipeline

Only a very small number of users should be a member of the system administration group.

Note that members of the user administration group are not able to add users to the system administration group.

---

## Infrastructure ##
`/terraform/infrastructure`

The infrastructure scripts generate a complete AWS environment fo deploying containers. The AWS access keys used when executing the scripts must correspond to an AWS user with permission to actually create all of the required AWS assets. Making the user a member of the `CCS_System_Administration`, `CCS_Infrastructure_Administration` and `CCS_Code_Build_Pipeline` IAM groups will ensure this.

- VPC across three availability zone: *Only Zone 'a' is populated at present.*
  - Public, private and management subnets within each availability zone.
  - Private DNS zone in Route 53 assigned to the VPC.
  - Network ACL rules.
- Security groups to control access to various features and functions.
- A basic  bastion host for management.
- Two ECS clusters:
  - **CCSDEV_app_cluster** for 'Applications' in the public subnet.
  - **CCSDEV_api_cluster** for 'Apps' in the private subnet.
- Public application load balancer for the application cluster.
  - HTTP only for initial release.
- Internal application load balancer for the ap cluster.
  - HTTP only for initial release.

---

## Build Pipeline Examples
`/terraform/build`

Thee are examples the create AWS CodePipeline and CodeBuild configurations for an application (*app1*), an api (*api1*). These will take source code from Github and, ultimately, deploy an updated container image to the correct ECS cluster. There is also an example the published an updated NPM module to [https://www.npmjs.com](https://www.npmjs.com).

Each of these examples will generate AWS CodeBuild and CodePipeline configurations. The content of these will vary with the type of build. For example, an NPM module build will not create or update any ECS task definitions.

All of these builds require an environment variable, `GITHUB_TOKEN`, that must contain a valid access token for Github.

### Application Example ###
`/terraform/build/app1`

This uses the contents of the `CCSExampleApp1` repository. It contains a minimal NodeJS/Express application and a Dockerfile for defining the container image.

The file `main.tf` defines the attributes of the build and identifies the location of the source code in Github, the name of cluster to which it will be deployed and the type of build to be performed. It also contains a variable that specifies the root domain name for the Route 53 zone to which a 'A' record will be added to make the application accessible. The name and prefix settings will be combined to form the container image name within ECR.

When executed the scripts will define the build pipeline and this will trigger the process of building and deploying the example application. Eventually, assuming the build succeeds, the application will be accessible as `http://app1.<domain>`.

### Api Example ###
`/terraform/build/api1`

This uses the contents of the `CCSExampleApi1` repository. It contains a minimal Java/Springboot REST API and a Dockerfile for defining the container image.

The file `main.tf` defines the attributes of the build and identifies the location of the source code in Github, the name of cluster to which it will be deployed and the type of build to be performed. It also contains a variable that specifies the root domain name for the Route 53 zone to which a 'A' record will be added to make the api accessible. The default value for this is the private zone only usable within the VPC. The name and prefix settings will be combined to form the container image name within ECR.

When executed the scripts will define the build pipeline and this will trigger the process of building and deploying the example api. Eventually, assuming the build succeeds, the application will be accessible as `http://api1.<domain>`. Note that with the settings in the example this is deployed to the api cluster within a private subnet. To test one option is to ssh to the basiton host and execute `curl`. See the documentation within the `CCSExampleApi1` repository for details REST interface.


### NPM Module Example ###
`/terraform/build/npm1`

This uses the contents of the `CCSExampleNPMModule` repository. It contains a minimal JavaScript module that can be built and published as an NPM module.

The file `main.tf` defines the attributes of the build and identifies the location of the source code in Github. An environment variable, `NPM_TOKEN` must be defined that is able to publish to the NPM registry on [https://www.npmjs.com](https://www.npmjs.com).

When executed the scripts will define the build pipeline and this will trigger the process of building and publishing the example NPM module.

---

## Environment variables passed to containers ##

The build pipeline scripts will ensure that a number of environment variables are passed to the running containers. Of particular importance are those variables that allow an *app* container to determine the URL for invoking an *api*. These are:

 - CCS_API_PROTOCOL
 - CCS_API_BASE_URL
 - CCS_APP_PROTOCOL
 - CCS_APP_BASE_URL

 The *PROTOCOL* variables will contain either *http* or *https*. The *BASE_URL* variables contain the domain name for accessing applications or apis.

 An application can construct a URL for accessing api1 using:

 `CCS_API_PROTOCOL + "://" + "api1." + CCS_API_BASE_URL`

The example NPM module actually contains a simple class for this purpose and is used by the example application.

Environment variables can also be used to pass feature switches to containers. These variables should all be  prefixed with `CCS_FEATURE_` and contain a value of `on` or `off`. For example

`CCS_FEATURE_EG1=on`



