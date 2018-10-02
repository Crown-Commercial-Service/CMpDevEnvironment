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

---

## S3 Buckets ##
S3 buckets are used in the build pipeline for temporary artefacts. A bucket name must be globally unique. To ensure that multiple CCS environments can be created the bucket name will include the AWS account number.

```ccs.<account number>.build-artifacts```

Note that if a ```terraform destroy` is being performed the contents of the bucket must be manually deleted first.

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

variable "default_db_name" {
  default = "cmpdefault"
}

variable "default_db_username" {
  default = "ccsdev"
}

variable "default_db_password" {
  default = "????????"
}
```

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




