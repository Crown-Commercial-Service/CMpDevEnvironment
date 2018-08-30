Terraform Scripts for Rebuilding CCS AWS environment
====================================================

These scripts use Terraform from Hashicorp (https://www.terraform.io/) to recreate the AWS environment. This includes the:
VPC definition
Subnet
Internet gateway
NAT gateway
Routing tables
Network ACL
Private DNS zone for the VPC
Security groups
Small Linux EC2 server as a bastion host
ECS Clusters

What these scripts do NOT do
----------------------------

	It does not define or add any records to the ??? CCS domain.


Using the scripts
-----------------
This assumes the files are checked out from bitbucket, Terraform is already installed and a suitable Amazon AWS account is available.

1/ Edit variables.tf to provide the access key and secret for an IAM defined account on AWS. This account must be able to create, modify and delete all
assets.

2/ Edit variables.tf to ensure that suitable AMIs and key names are specified.

3/ Execute 'terraform init'

4/ Execute 'terraform apply', review the proposed changes and enter 'yes' to execute the plan.



