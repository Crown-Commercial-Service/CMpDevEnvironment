##############################################################
# Create Parameter store entries to generate Gov Notify
# environment variable.
##############################################################
resource "aws_ssm_parameter" "gov_notify_api_key" {
  name  = "/Environment/ccs/cmp/GOV_NOTIFY_API_KEY"
  description  = "Infrastructure configured Gov Notify API Key"
  type  = "SecureString"
  value = "the_gov_notify_api_key_value_would_go_in_here"
  overwrite = true
  
  tags {
    Name = "Parameter Store: Infrastructure configured Gov Notify API Key"
    CCSRole = "Infrastructure"
  }
}
