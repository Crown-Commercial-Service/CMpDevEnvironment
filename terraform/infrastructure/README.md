# CCS CMp Environment Infrastructure

## Security Groups
A number of security groups are defined that have specific purposes. Some are used within the VPC, their name will contain `internal`, others control access from the public Internet, their name will contain `external`. At present the `external` groups will be restricted by IP address.

The configuration for external access is via variables, which will need to be overridden locally.
This should be done by creating a variable file ending with `.auto.tfvars` which will be ignored by git and therefore not committed into source control.
An example `config.auto.tfvars` (as found in `config.auto.tfvars.example`) might look as follows (NOTE These are not valid address ranges):
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
### CCSDEV-internal-ssh ###
Allows inbound ssh access within the VPC. Used to allow the bastion host to ssh to the actual ECS EC2 instances if needed.

### CCSDEV-internal-app ###
Controls access to the application cluster ECS EC2 instances from within the VPC. This access is used by the load balancer to route requests and health checks.

### CCSDEV-internal-api ###
Controls access to the api ECS EC2 instances from within the VPC. This access is used by the load balancer to route requests and health checks. It can also be used from the bastion host, for example, an api could be tested by executing curl on the bastion.

### CCSDEV-internal-PG-DB ###
Controls access to PostgreSQL RDS instances deployed within the VPC. There are none at present. Access is only allowed from the private and management subnets.

### CCSDEV-internal-api-alb ###
Controls access to the api cluster load balancer. Access is only allowed from within the VPC restricting api requests from the application cluster, other apis and the bastion.

### CCSDEV-external-ssh ###
Controls ssh access from the public Internet. This should specify the minimum number of IP addresses needed.

### CCSDEV-external-app ###
Controls direct access to the application cluster, by-passing the load balancer. This is currently empty but may prove useful during testing and development to access containers deployed within the application cluster but not connected to the load balancer.

### CCSDEV-external-app-alb ###
Controls access to the application load balancer from the public Internet.

### CCSDEV-internal-PG-DB ###
Controls access to the example RDS Postgres database. **Note** currently allowing access from public and private subnets. This will be removed in a later release.

### CCSDEV-internal-ES ###
Controls access to the example Elastic Search domain. **Note** currently allowing access from public and private subnets. This will be removed in a later release.

### CCSDEV-internal-EC-REDIS ###
Controls access to the ElastiCache Redis instance. **Note** currently allowing access from public and private subnets. This will be removed in a later release.

---

## S3 Buckets ##
S3 buckets are used in the build pipeline for temporary artefacts. A bucket name must be globally unique. To ensure that multiple CCS environments can be created the bucket name will include the AWS account number.

```ccs.<account number>.build-artifacts```

Note that if a ```terraform destroy` is being performed the contents of the bucket must be manually deleted first.

An S3 bucket is also created for use by application and API containers. The containers execute with an IAM role that allows full access to S3. The bucket name is:

```ccs.<account number>.<environment_name>.app-api-data```

The name of the bucket is passed to containers in the environment variable: `CCS_APP_API_DATA_BUCKET`.

An S3 bucket is created with public access for storing assets to be served be the web application.

```<account number>.assets```

The name of the bucket is passed to containers in the environment variable: `ASSETS_BUCKET`.

---

## EC2 Instances ##
EC2 instances are defined for the cluster and bastion. ECS Fargate is not available in the `eu-west-2` region so explicit definition of the instances is still required.

### Application ECS Cluster ###
A set of variables in `variables.tf' is used to control the instance class and number of instances:

```
variable "app_cluster_ami" {
  default = "ami-a44db8c3"
}

variable "app_cluster_instance_class" {
  default = "m4.large"
}

variable "app_cluster_instance_count" {
  default = "1"
}

variable "app_cluster_key_name" {
  default = "ccs_cluster"
}
```

### Api ECS Cluster ###
A set of variables in `variables.tf' is used to control the instance class and number of instances:

```
variable "app_cluster_ami" {
  default = "ami-a44db8c3"
}

variable "app_cluster_instance_class" {
  default = "m4.large"
}

variable "app_cluster_instance_count" {
  default = "1"
}

variable "app_cluster_key_name" {
  default = "ccs_cluster"
}
```

### Bastion ###
A set of variables in `variables.tf' is used to control the instance class:

```
variable "bastion_ami" {
  default = "ami-dff017b8"
}

variable "bastion_instance_class" {
  default = "t2.micro"
}

variable "bastion_key_name" {
  default = "ccs_bastion"
}

variable "bastion_storage" {
  default = 8
}
```

---

## Example RDS Database ##
A set of variables in `variables.tf' is used to define the example RDS database instance. Note the flag that can be used to prevent creation of the database:

```
variable "create_default_rds_database" {
  default = true
}

variable "default_db_instance_class" {
  default = "db.t2.medium"
}

variable "default_db_storage" {
  default = 20
}

variable "default_db_apply_immediately" {
  default = true
}

variable "default_db_name" {
  default = "cmpdefault"
}

variable "default_db_username" {
  default = "ccsdev"
}

variable "default_db_password" {
  default = ""
}
```

If the `default_db_password` entry is left as an empty string a random password will be generated. This is the recommended approach.

When the database instance is created an entry in the private Route53 zone will be created that points to the database host. This will be in the form:

`[database name].db.[internal domain]`

for example:

`cmpdefault.db.internal.cmpdev.crowncommercial.gov.uk`

By default the database will insist on an SSL connection.

---

## Example elastic Search Domain ##
A set of variables in `variables.tf' is used to define the example Elastic Search domain. Note the flag that can be used to prevent creation of the domain:

```
variable "create_elasticsearch_default_domain" {
  default = true
}

variable "elasticsearch_default_domain" {
  default = "cmpdefault"
}

variable "elasticsearch_default_instance_class" {
  default = "c4.large.elasticsearch"
}
```

When the Elastic Search instance is created an entry in the private Route53 zone will be created that points to the search end point. This will be in the form:

`[domain name].es.[internal domain]`

for example:

`cmpdefault.es.internal.cmpdev.crowncommercial.gov.uk`

Note that Elastic Search will listen on http and https. The certificate used for https is generated automatically be AWS and will **not** match the above host name.

---

## ElastiCache Redis Instance ##
A set of variables in `variables.tf' is used to define the ElastiCache Redis instance. Note the flag that can be used to prevent creation of the instance:

```
variable "create_elasticache_redis" {
  default = true
}

variable "elasticache_instance_class" {
  default = "cache.t2.small"
}
```

When the Redis instance is created an entry in the private Route53 zone will be created that points to the Redis end point. This will be in the form:

`redis.[internal domain]`

for example:

`redis.internal.cmpdev.crowncommercial.gov.uk`

---


## Cloudwatch Dashboard and Logs ##
A basic dashboard, `CCSDEV-Dashboard` is defined. This provides access to a number of graphs:

- Example Application CPU and memory utilisation.
- Example Api CPU and memory utilisation.
- Application cluster target response time 
- Api cluster target response time
- Application cluster average requests/minute
- Api cluster average requests/minute
- Application cluster http 4xx and 5xx errors
- Api cluster http 4xx and 5xx errors

Log groups can be viewed for each deployed application and api. These are collected from the container stdout and stderr. They will be within a Log Group that corresponds to the container name.

The build pipeline also generates log groups. These will contain any output during the build process including, where available, unit test results. These groups will have names in in the form

`/aws/codebuild/<app or api name>-build-project`

---
## Cognito User Pool ##
Cognito is an AWS service that can be used to provide user authentication, and for certain AWS assets, authorisation. Within the CCS Infrastructure it can be used to by suitably modified Application and APIs to provide authentication.

To facilitate this a single user pool, `ccs_user_pool` is defined within the infrastructure Terraform. This provides a set of users, identified by an email address, and authenticated by a password. Settings on the `cognito.tf` file allow the enabling/disabling of user self-registration and basic password policies to be defined:

```
    # User self-registration enabled, set to true to prevent self-registration.
    admin_create_user_config {
      allow_admin_create_user_only = false
    }

    # Set basic password restrictions    
    password_policy {
        minimum_length    = 8
        require_lowercase = true
        require_numbers   = true
        require_symbols   = true
        require_uppercase = true
    }
```

Details of the user pool are made available to the Application and API containers via environment variables:

 - COGNITO_AWS_REGION 
 - COGNITO_USER_POOL_ID
 - COGNITO_USER_POOL_SITE

An application client that users the pool is created for each Application or API that enables Cognito support in its Terraform definition. Note that they *ALL* shared the same pool of users. This will also generate an Application/API specific environment variable, `COGNITO_CLIENT_ID`, identifying the corresponding Cognito client identifier.

AWS Cognito supports extensive customisation, often using Lambda functions, it is highly likely that such customisation will be required before production use.


