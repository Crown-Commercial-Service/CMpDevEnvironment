

data "aws_ssm_parameter" "cognito_user_pool_id" {
  name  = "/Environment/global/COGNITO_USER_POOL_ID"
}

##############################################################
# Client configuration supporting secret.
##############################################################
resource "aws_cognito_user_pool_client" "ccs_user_pool_client" {
    name = "ccs_user_pool_client"
    user_pool_id = "${data.aws_ssm_parameter.cognito_user_pool_id.value}"
    generate_secret = true 
    allowed_oauth_flows = ["code"]
    allowed_oauth_flows_user_pool_client = true
    allowed_oauth_scopes = ["openid", "email"]
    callback_urls = ["https://${local.config_hostname}.${local.config_domain}/auth/cognito/callback"]
    logout_urls = ["https://${local.config_hostname}.${local.config_domain}/"]
    supported_identity_providers = ["COGNITO"]
}


##############################################################
# Create Parameter store entries to generate container
# environment variables.
##############################################################
resource "aws_ssm_parameter" "cognito_user_pool_client_id" {
  name  = "/Environment/${var.prefix}/${var.name}/COGNITO_CLIENT_ID"
  description  = "Infrastructure configured AWS Cognito User Pool Client ID"
  type  = "SecureString"
  value = "${aws_cognito_user_pool_client.ccs_user_pool_client.id}"

  tags {
    Name = "Parameter Store: Infrastructure configured AWS Cognito User Pool Client ID"
    CCSRole = "Infrastructure"
  }
}

resource "aws_ssm_parameter" "cognito_user_pool_client_secret" {
  name  = "/Environment/${var.prefix}/${var.name}/COGNITO_CLIENT_SECRET"
  description  = "Infrastructure configured AWS Cognito User Pool Client secret"
  type  = "SecureString"
  value = "${aws_cognito_user_pool_client.ccs_user_pool_client.client_secret}"

  tags {
    Name = "Parameter Store: Infrastructure configured AWS Cognito User Pool Client secret"
    CCSRole = "Infrastructure"
  }
}
