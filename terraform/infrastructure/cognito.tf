##############################################################
#
# CCSDEV    AWS Cognito Configuration
#
# This script configures a minimal Cognito service.
#
# This provide a user/apssword authentication service that
# is shared across the whole application cluster.
#
# It is NOT application specific.
#
# Note the the AWS account ID is used as the Cognito domain
# prefix. This may be be the best approach in the long term.
#
# A number of (global) environment variables are created via
# entries in the EC2 parameter store:
#
# COGNITO_USER_POOL_ID
# COGNITO_USER_POOL_SITE
# COGNITO_CLIENT_ID
# COGNITO_CLIENT_SECRET
# AWS_REGION
#
##############################################################
locals {
    region = "eu-west-2"
}

##############################################################
# Basic user pool using email verification. THe user name
# must be an email address.
##############################################################
resource "aws_cognito_user_pool" "ccs_user_pool" {
    name = "ccs_user_pool"
    username_attributes = ["email"]
    auto_verified_attributes = ["email"]
    email_verification_subject = "Your Verification code"
    email_verification_message = "Your Verification code is {####}"
  
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
  
    tags {
        Name = "CCSDEV Services"
        CCSRole = "Infrastructure"
    }
}

##############################################################
# Domain using the current AWS account ID
##############################################################
resource "aws_cognito_user_pool_domain" "ccs_cmp_domain" {
  domain = "${data.aws_caller_identity.current.account_id}"
  user_pool_id = "${aws_cognito_user_pool.ccs_user_pool.id}"
}

##############################################################
# Create Parameter store entries to generate container
# environment variables.
##############################################################
resource "aws_ssm_parameter" "cognito_aws_region" {
  name  = "/Environment/global/COGNITO_AWS_REGION" 
  description  = "Infrastructure configured AWS Region for Cognito"
  type  = "SecureString"
  value = "${local.region}"

  tags {
    Name = "Parameter Store: Infrastructure configured AWS Region for Cognito"
    CCSRole = "Infrastructure"
  }
}

resource "aws_ssm_parameter" "cognito_user_pool_id" {
  name  = "/Environment/global/COGNITO_USER_POOL_ID"
  description  = "Infrastructure configured AWS Cognito User Pool ID"
  type  = "SecureString"
  value = "${aws_cognito_user_pool.ccs_user_pool.id}"

  tags {
    Name = "Parameter Store: Infrastructure configured AWS Cognito User Pool ID"
    CCSRole = "Infrastructure"
  }
}

resource "aws_ssm_parameter" "cognito_user_pool_site" {
  name  = "/Environment/global/COGNITO_USER_POOL_SITE"
  description  = "Infrastructure configured AWS Cognito Pool site"
  type  = "SecureString"
  value = "https://${aws_cognito_user_pool_domain.ccs_cmp_domain.domain}.auth.${local.region}.amazoncognito.com"

  tags {
    Name = "Parameter Store: Infrastructure configured AWS Cognito Pool site"
    CCSRole = "Infrastructure"
  }
}