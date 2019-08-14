# Crown Commercial Environment (Production) #

This project contains [Terraform](https://www.terraform.io/) scripts that are used to generate a container hosting environment in AWS. This environment is in the eu-west-2 region.

This environment allows the deployment of externally accessible *Application* containers and private *API* containers. Example build pipelines for an application, api and NPM module are also provided.

The available scripts are divided into three areas: security, infrastructure and build pipelines. When creating a new environment scripts will need to be initially executed in that order.

All of the scripts will require `terraform init` to be executed in the correct directory.

---

## Additional Documentation ##

Some additional documentation is also available:

  * [Setup Guide](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/blob/production/docs/setup.md)
  * [Update Guide](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/blob/production/docs/update.md)
  * [Developer Guide](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/blob/production/docs/ccs_aws_v1-developer_guide.md)
---

## IAM Security ##
`/terraform/security`

The security scripts generate a number of IAM user groups and policies documents. They do not create any actual users.

The following groups are created:

- CCS_System_Administration
- CCS_User_Administration
- CCS_Infrastructure_Administration
- CCS_Application_Developer
- CCS_API_Developer
- CCS_Code_Build_Pipeline
- CCS_Cognito_Administration
- CCS_Terraform_Execution
- CCS_Developer_API_Access

Only a very small number of users should be a member of the system administration group. To have complete system administration privileges a user will need to be a member of the system administration, infrastructure administration and code build pipeline groups.

The `CCS_Terraform_Execution` group is available to give additional AWS users the capability to run Terraform scripts via the shared-state.

Note that members of the user administration group are not able to add users to the system administration group.

More information is available in the `terraform/security` directory.

---

## Infrastructure ##
`/terraform/infrastructure`

The infrastructure scripts generate a complete AWS environment for deploying containers. The AWS access keys used when executing the scripts must correspond to an AWS user with permission to actually create all of the required AWS assets. Making the user a member of the `CCS_System_Administration`, `CCS_Infrastructure_Administration` and `CCS_Code_Build_Pipeline` IAM groups will ensure this.

- VPC across three availability zone: *Only Zone 'a' is populated at present.*
  - Public, private and management subnets within each availability zone.
  - Private DNS zone in Route 53 assigned to the VPC.
  - Network ACL rules.
- Security groups to control access to various features and functions.
- A basic bastion host for management.
- Two ECS clusters:
  - **CCSDEV_app_cluster** for 'Applications' in the public subnet.
  - **CCSDEV_api_cluster** for 'APIs' in the private subnet.
- Public application load balancer for the application cluster.
  - HTTP and HTTPS using AWS managed certificates.
- Internal application load balancer for the api cluster.
  - HTTP and HTTPS using AWS managed certificates.
- Example RDS Postgres daatbase server. 
- Example Elastic Search domain.
- CloudWatch dashboard definition example
- Cognito user pool

**NOTE**
In this release the example database and Elastic Search instances can be accessed from the Application and API clusters. The intention is that this is restricted to the API cluster in the next release.

A file with the suffix `.auto.tfvars` must be created that defines the IP addresses from which access is allowed and the root domain name defined in Route53. An example file, `config.auto.tfvars.example` is provided:

```
# The domain name that the components will sit beneath
domain_name = "example.com"

# The subdomain beneath the main domain name that will be used for
#  internal (api) components - this defaults to "internal"
domain_internal_prefix = "internal"

# Whether HTTPS should be available across the load balancers
#  along with appropriate certificates
enable_https = false

# A map of external CIDR blocks that should have SSH access
"ssh_access_cidrs" = {
    "office" = "192.0.2.0/24"
}

# A map of external CIDR blocks that should have HTTP(S) access
"app_access_cidrs" = {
    "office" = "192.0.2.0/24"
    "guests" = "198.51.100.0/24"
}
```

When the infrastructure scripts are executed a number of settings are written to the `EC2 Parameter Store` as secure strings. These settings are then used to when creating the build pipelines to generate environment variables that are passed to running containers. In this way database and Elastic Search connection details are passed to the Applications and APIs.


---

## Marketplace Build Pipelines
`/terraform/build`

There are two build projects needed to deploy the Marketplace application, a custom build image for Ruby projects and the actual Marketplace application.

### image-ruby
`/terraform/build/image-ruby`

This pipeline generates a custom AWS CodeBuild image that is used to build and test the main marketplace application. This pipeline must be deployed and a build successfully completed before the application pipeline can be created.

### crown-marketplace
`/terraform/build/crown-marketplace`

This is the main Marketplace application that is built from the master branch of the crown-marketplace repository.

### crown-marketplace-production
`/terraform/build/crown-marketplace-production`

This is the main Marketplace application that will, eventually, build from the production branch of the crown-marketplace repository.

---

## Build Pipeline Examples
`/terraform/build`

There are examples that create AWS CodePipeline and CodeBuild configurations for an application (*app1*, *app2*), and an api (*api1*, *api2*). These will take source code from Github and, ultimately, deploy an updated container image to the correct ECS cluster. There is also an example that publishes an updated NPM module to [https://www.npmjs.com](https://www.npmjs.com).

Each of these examples will generate AWS CodeBuild and CodePipeline configurations. The content of these will vary with the type of build. For example, an NPM module build will not create or update any ECS task definitions.

All of these builds require access to a GitHub account for a GitHub token. This must be entered into the EC2 parameter store as a secure string called: `ccs-build_github_token`.They each use pre-defined buildspec files that are [located within the terraform build module](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/tree/production/terraform/modules/build) as &lt;prefix&gt;_buildspec.yml.

### Application Example 1 ###
`/terraform/build/app1`

This uses the contents of the `CMpExampleApp1` repository. It contains a minimal NodeJS/Express application and a Dockerfile for defining the container image.

The file `main.tf` defines the attributes of the build and identifies the location of the source code in Github, the name of the cluster to which it will be deployed and the type of build to be performed. It also contains a variable that specifies the root domain name for the Route 53 zone to which an 'A' record will be added to make the application accessible. The name and prefix settings will be combined to form the container image name within ECR.

When executed the scripts will define the build pipeline and this will trigger the process of building and deploying the example application. Eventually, assuming the build succeeds, the application will be accessible as `http://app1.<domain>`.

### Application Example 2 ###
`/terraform/build/app2`

This uses the contents of the `CMpExampleApp2` repository. It contains a minimal Ruby on Rails application and a Dockerfile for defining the container image.

The file `main.tf` defines the attributes of the build and identifies the location of the source code in Github, the name of the cluster to which it will be deployed and the type of build to be performed. It also contains a variable that specifies the root domain name for the Route 53 zone to which an 'A' record will be added to make the application accessible. The name and prefix settings will be combined to form the container image name within ECR.

When executed the scripts will define the build pipeline and this will trigger the process of building and deploying the example application. Eventually, assuming the build succeeds, the application will be accessible as `http://app2.<domain>`.

### Api Example 1 ###
`/terraform/build/api1`

This uses the contents of the `CMpExampleApi1` repository. It contains a minimal Java/Springboot REST API and a Dockerfile for defining the container image.

The file `main.tf` defines the attributes of the build and identifies the location of the source code in Github, the name of cluster to which it will be deployed and the type of build to be performed. It also contains a variable that specifies the root domain name for the Route 53 zone to which an 'A' record will be added to make the api accessible. The default value for this is the private zone only usable within the VPC. The name and prefix settings will be combined to form the container image name within ECR.

When executed the scripts will define the build pipeline and this will trigger the process of building and deploying the example api. Eventually, assuming the build succeeds, the api will be accessible as `http://api1.<domain>`. Note that with the settings in the example this is deployed to the api cluster within a private subnet. To test, one option is to ssh to the basiton host and execute `curl`. See the documentation within the `CMpExampleApi1` repository for details of the REST interface.

### Api Example 2 ###
`/terraform/build/api2`

This uses the contents of the `CMpExampleApi2` repository. It contains a minimal Python + Flask REST API and a Dockerfile for defining the container image.

The file `main.tf` defines the attributes of the build and identifies the location of the source code in Github, the name of cluster to which it will be deployed and the type of build to be performed. It also contains a variable that specifies the root domain name for the Route 53 zone to which an 'A' record will be added to make the api accessible. The default value for this is the private zone only usable within the VPC. The name and prefix settings will be combined to form the container image name within ECR.

When executed the scripts will define the build pipeline and this will trigger the process of building and deploying the example api. Eventually, assuming the build succeeds, the api will be accessible as `http://api2.<domain>`. Note that with the settings in the example this is deployed to the api cluster within a private subnet. To test, one option is to ssh to the basiton host and execute `curl`. See the documentation within the `CMpExampleApi2` repository for details of the REST interface.


### NPM Module Example ###
`/terraform/build/npm1`

This uses the contents of the `CCSExampleNPMModule` repository. It contains a minimal JavaScript module that can be built and published as an NPM module.

The file `main.tf` defines the attributes of the build and identifies the location of the source code in Github. The example uses a bespoke build type of npm-publish which will install the package, run any tests and then attempt to publish the package to the npmjs registry - In order for this to be successful, there is a predefined npm auth token stored within the AWS parameter store (ccs-build_npm_token).

When executed the scripts will define the build pipeline and this will trigger the process of building and publishing the example NPM module.


### Ruby Image Example ###
`/terraform/build/image-ruby`

This uses the contents of the `CMpDevBuildImage_Ruby` repository which contains a Dockerfile and associated context that can be built and published as docker image within the AWS Container Registry for use in other builds.

The file `main.tf` defines the attributes of the build and identifies the location of the source code in Github. The image build type uses a 2-stage pipeline that will build the container image and then publish it to the AWS Container Registry.

The produced image can be used in subsequent component builds by setting the `build_type` variable to `'custom'` and the `'build_image'` variable to `'{Image Prefix}/{Image Name}'` as specified when the image was built. For example:

`build_image = "ccs/ruby"`

### Maintenance/Service Unavailable Application ###
`/terraform/build/cmp-maintenance`

This uses the contents of the `crown-marketplace-maintenance` to build and deploy a small nodeJS application that displays a static HTML page. The file `main.tf` contains a setting, `catch_all` that will configure the application load balancer to direct any request to a non-existant application to this page.

**NOTE** : The operation of the `catch-all` settings is dependent on the ordering of rules within the application load balancer listener rules. It is not always possible for Terraform to maintain this list in the correct order.

### Crown Marketplace Application ###
`/terraform/build/crown-marketplace`

This is the actual Marketplace application taken from the `crown-marketplace` repository. It is a Ruby application and the build pipeline will use the custom Ruby build image described previously. This must be available as an image in the AWS Elastic Container Repository (ECR) before the application pipeline is created.

### Crown Marketplace Data Upload Application ###
`/terraform/build/crown-marketplace-upload`

This is the actual Marketplace application taken from the `crown-marketplace` repository. However it is deployed to the `API Cluster` and, as can be seen in the file `main.tf`, sets the `APP_HAS_UPLOAD_PRIVILEGES` environment variable. This allows it to be used to upload data to the marketplace application. Because it is deployed to the `API Cluster` this capability can only be accessed from within the VPC.  

### Uploading Supply Teacher Data ###
`/terraform/build/upload-supply-teacher-data`

This pipeline uses the `crown-marketplace-data` repository to detect changes to the data available for the application and, when changes are committed, will upload the supply teacher related data to the application by POSTing the data to the Marketplace  application deployed to the `API Cluster`. The data is uploaded using the same process described in the `crown-marketplace` repository documentation. 

---

## Build Pipeline Notifications

When the build pipelines are created AWS Simple Notification Service (SNS) `topics` are also created. Each pipeline will have two topics, that represent successful and failed builds. AWS console users can subscribe to these topics to receive, via email, notification of the corresponding event.

### Successful Builds
Topic: `[pipeline name]-success`
Notification generated when the pipeline state changes to `SUCCEEDED`.

### Failed Builds
Topic: `[pipeline name]-failure`
Notification generated when the pipeline state changes to `FAILED`.

AWS Console users who are members of the `CCS_Application_Developer` and `CCS_Application_Developer` IAM groups receive permissions that allow them to subscribe to the topics.

---

## Pre-defined Environment variables passed to containers ##

The build pipeline scripts will ensure that a number of environment variables are passed to the running containers. Of particular importance are those variables that allow an *app* container to determine the URL for invoking an *api*. These are:

 - CCS_API_PROTOCOL
 - CCS_API_BASE_URL
 - CCS_APP_PROTOCOL
 - CCS_APP_BASE_URL

 The *PROTOCOL* variables will contain either *http* or *https*. The *BASE_URL* variables contain the domain name for accessing applications or apis.

 An application can construct a URL for accessing api1 using:

 `CCS_API_PROTOCOL + "://" + "api1." + CCS_API_BASE_URL`

The example NPM module actually contains a simple class for this purpose and is used by the example application.

Database, Redis and Elastic Search connection information is also supplied as environment variables:

- CCS_DEFAULT_DB_URL
- CCS_DEFAULT_DB_TYPE
- CCS_DEFAULT_DB_HOST
- CCS_DEFAULT_DB_PORT
- CCS_DEFAULT_DB_NAME
- CCS_DEFAULT_DB_USER
- CCS_DEFAULT_DB_PASSWORD
- CCS_REDIS_HOST
- CCS_REDIS_PORT
- CCS_DEFAULT_ES_ENDPOINT


`CCS_DEFAULT_DB_URL` is JDBC style connection string for accessing the database. The `CCS_DEFAULT_DB_TYPE`, `CCS_DEFAULT_DB_HOST`, `CCS_DEFAULT_DB_PORT` and `CCS_DEFAULT_DB_NAME` variables the contain individual values that can be used to established a database connection. 

Var variable `CCS_VERSION` is also defined. It will contain the contents of a file called `CCS_VERSION` from the root of the application or API repository. If no file is present it will contain `0.0.1`.

Environment variables can also be used to pass feature switches to containers. These variables should all be  prefixed with `CCS_FEATURE_` and contain a value of `on` or `off`. For example

The Application/API data S3 bucket is passed in th environment variable: `CCS_APP_API_DATA_BUCKET`.


`CCS_FEATURE_EG1=on`

## Environment variables passed to containers from the EC2 Parameter Store ##
Certain entries in the EC2 Parameter store will be automatically turned into environment variables and passed to the
running container. These entries can be *global* that will be passed to all containers or specific to an Application or API.

For a global variable the format is `/Environment/global/{Variable Name}`

For an Application or API specific variable the format is `/Environment/{App or API prefix}/{App or API Name}/{Variable Name}`

For example a Parameter Store entry:

`/Environment/ccs/cmp/GOOGLE_GEOCODING_API_KEY` set to `'QWERTY'`

Will result in an environment variable `GOOGLE_GEOCODING_API_KEY` with the value of `'QWERTY'` being available to the running container.

Note that these settings are handled by re-writing the Application or API `Dockerfile` during the build process. To facilitate this the `Dockerfile` must contain a special marker to indicate where the additional environment variables should be injected: `##_PARAMETER_STORE_MARKER_##`.

For example:

```
ARG BUILD_TIME
LABEL build_time=$BUILD_TIME
ENV BUILD_TIME=$BUILD_TIME

ARG CCS_VERSION
LABEL ccs_version=$CCS_VERSION
ENV CCS_VERSION=$CCS_VERSION

##_PARAMETER_STORE_MARKER_##

ENV BUILD_PACKAGES curl-dev ruby-dev postgresql-dev build-base tzdata

# Update and install base packages
RUN apk update && apk upgrade && apk add bash $BUILD_PACKAGES nodejs-current-npm git
```

**NOTE**: For a change to a variable defined in this way to take affect the application/API the build pipeline must executed. This will require either a change in the source repository, or more simply, the selection of the `Release change` option from the CodePipeline area of the AWS Console.







