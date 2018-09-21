# CCS Environment Infrastructure

## Security Groups
A number of security groups are defined that have specific purposes. Some are used within the VPC, their name will contain `internal`, others control access from the public Internet, their name will contain `external`. At present the `external` groups will be restricted by IP address.

The configuration for external access is via variables, which will need to be overridden locally.
This should be done by creating a variable file ending with `.auto.tfvars` which will be ignored by git and therefore not committed into source control.
An example `access_cidrs.auto.tfvars` might look as follows (NOTE These are not valid address ranges):
```
"ssh_access_cidrs" = {
    "office" = "192.0.2.0/24"
}

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
  default = "m5.large"
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
  default = "m5.large"
}

variable "app_cluster_instance_count" {
  default = "1"
}

variable "app_cluster_key_name" {
  default = "ccs_cluster"
}
```

### Bastion ###
A set of variables in `variables.tf' is used to control the instance clas:
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

### Cloudwatch Dashboard and Logs ###
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




