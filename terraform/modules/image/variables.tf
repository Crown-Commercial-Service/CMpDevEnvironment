##############################################################
# Image Prefix  
##############################################################
variable prefix {
    type = "string"
    default = "ccs"
}

##############################################################
# Image Name
##############################################################
variable name {
    type = "string"
}

##############################################################
# Image source Github user/org
##############################################################
variable github_owner {
    type = "string"
}

##############################################################
# Image source Github repo
##############################################################
variable github_repo {
    type = "string"
}

##############################################################
# Image source Github branch
##############################################################
variable github_branch {
    type = "string"
    default = "master"
}

##############################################################
# Image source Github token alias as used in
#  the Parameter Store
##############################################################
variable github_token_alias {
    type = "string"
}

data "aws_caller_identity" "current" {
}

##############################################################
# IAM references
##############################################################

data "aws_iam_role" "codebuild_service_role" {
  name = "codebuild-api-service-role"
}

data "aws_iam_role" "codepipeline_service_role" {
  name = "codepipeline-api-service-role"
}

##############################################################
# Infrastructure references
##############################################################

data "aws_vpc" "CCSDEV-Services" {
  tags {
    "Name" = "CCSDEV Services"
  }
}

data "aws_subnet" "CCSDEV-AZ-a-Private-1" {
  tags {
    "Name" = "CCSDEV-AZ-a-Private-1"
  }
}

data "aws_subnet" "CCSDEV-AZ-b-Private-1" {
  tags {
    "Name" = "CCSDEV-AZ-b-Private-1"
  }
}

data "aws_subnet" "CCSDEV-AZ-c-Private-1" {
  tags {
    "Name" = "CCSDEV-AZ-c-Private-1"
  }
}

data "aws_security_group" "vpc-CCSDEV-internal" {
  tags {
    "Name" = "CCSDEV-internal-api"
  }
}
