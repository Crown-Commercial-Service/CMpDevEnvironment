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
# Cognito user pool role for sending SMS
# Note Random guid for external id
##############################################################

resource "random_uuid" "CCSDEV_userpool_role_external_id" {

}

resource "aws_iam_role" "CCSDEV_userpool_role" {
  name               = "CCSDEV-cognito-userpool-role"
  description        = "Role for Cognito user pool for sending SMS"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.CCSDEV_userpool_role_trust_policy.json}"
}

data "aws_iam_policy_document" "CCSDEV_userpool_role_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cognito-idp.amazonaws.com"]
    }

    condition {
      test        = "StringEquals"
      variable    = "sts:ExternalId"
      values      = ["${random_uuid.CCSDEV_userpool_role_external_id.result}"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "CCSDEV_userpool_role_attachment" {
  role       = "${aws_iam_role.CCSDEV_userpool_role.name}"
  policy_arn = "${aws_iam_policy.CCSDEV_userpool_role_policy.arn}"
}

resource "aws_iam_policy" "CCSDEV_userpool_role_policy" {
  name   = "CCSDEV_userpool_role_policy"
  path   = "/"
  policy = "${data.aws_iam_policy_document.CCSDEV_userpool_role_policy_document.json}"
}

data "aws_iam_policy_document" "CCSDEV_userpool_role_policy_document" {

  statement {

    actions = [
      "sns:publish"
    ]

    resources = [
		"*"
    ]
  }

}


##############################################################
# Basic user pool using email verification. THe user name
# must be an email address.
##############################################################
resource "aws_cognito_user_pool" "ccs_user_pool" {
    name = "ccs_user_pool"
    username_attributes = ["email"]
    auto_verified_attributes = ["email"]
    email_verification_subject = "Crown Commercial Service Verification Code"
    email_verification_message = "<p>Hello,</p><p>Your Crown Commercial Service verification code is: <strong>{####}</strong></p><p>You must use this code within 24 hours of receiving this email.</p><p>Kind regards,<br>Customer Services Team<br>Crown Commercial Service</p>"

    # Support optional MFA via SMS
    mfa_configuration = "OPTIONAL"
    sms_configuration {
       external_id = "${random_uuid.CCSDEV_userpool_role_external_id.result}" 
       sns_caller_arn = "${aws_iam_role.CCSDEV_userpool_role.arn}" 
    }

    # User self-registration enabled, set to true to prevent self-registration.
    admin_create_user_config {
      allow_admin_create_user_only = false
      invite_message_template {
        email_subject = "Crown Marketplace - Your temporary password"
        email_message = "<p>Welcome to the Crown Marketplace.</p><p>Your username is {username} and temporary password is {####}</p><p><strong>NOTE.</strong>Your username is case-sensitive.</p><p>Access the site at https://marketplace.service.crowncommercial.gov.uk/.</p>"
        sms_message = "Welcome to the Crown Marketplace. Your username is {username} and temporary password is {####}"
      }
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
# Create required user pool groups
##############################################################

resource "aws_cognito_user_group" "ccs_user_pool_groups" {
  count        = "${length(keys(var.ccs_cognito_groups))}"
  name         = "${element(keys(var.ccs_cognito_groups), count.index)}"
  description  = "${element(values(var.ccs_cognito_groups), count.index)}"
  user_pool_id = "${aws_cognito_user_pool.ccs_user_pool.id}"
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

##############################################################
# Add custom policy to CCS_Developer_API_Access group and
# the container task role to
# allow access to the Cognito APIs.
# Note that a reduced capability policy should be used
# once all of the use-cases are determined.
##############################################################

resource "aws_iam_group_policy_attachment" "cognito_api-access" {
  group      = "CCS_Developer_API_Access"
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"

}

resource "aws_iam_role_policy_attachment" "CCSDEV_task_role_attachment_cognito_api" {
  role       = "CCSDEV-task-role"
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}
