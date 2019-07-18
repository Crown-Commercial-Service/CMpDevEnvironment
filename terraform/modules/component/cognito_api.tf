locals {
  enable_cognito_api = "${var.enable_cognito_api_support ? 1 : 0}"
}

data "aws_ssm_parameter" "cognito_user_pool_id" {
  count = "${local.enable_cognito_api}"
  name  = "/Environment/global/COGNITO_USER_POOL_ID"
}

##############################################################
# Client configuration supporting secret.
##############################################################
resource "aws_cognito_user_pool_client" "user_pool_client_api" {
  count = "${local.enable_cognito_api}"
  name = "${var.name}_user_pool_client"
  user_pool_id = "${data.aws_ssm_parameter.cognito_user_pool_id.value}"
  generate_secret = false 
}

##############################################################
# Create Parameter store entries to generate container
# environment variables.
##############################################################
resource "aws_ssm_parameter" "cognito_user_pool_client_api_id" {
  count = "${local.enable_cognito_api}"
  name  = "/Environment/${var.prefix}/${var.name}/COGNITO_CLIENT_ID"
  description  = "Infrastructure configured AWS Cognito User Pool Client ID"
  type  = "SecureString"
  value = "${aws_cognito_user_pool_client.user_pool_client_api.id}"

  tags {
    Name = "Parameter Store: Infrastructure configured AWS Cognito User Pool Client ID"
    CCSRole = "Infrastructure"
  }
}

