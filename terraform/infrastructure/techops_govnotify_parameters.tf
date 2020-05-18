##############################################################
# Create Parameter store entries to generate Gov Notify
# environment variable.
##############################################################
resource "aws_ssm_parameter" "gov_notify_api_key" {
  name  = "/Environment/ccs/cmp/GOV_NOTIFY_API_KEY"
  description  = "Infrastructure configured Gov Notify API Key"
  type  = "SecureString"
  value = "ccsapplicationkey-ea34b16b-8fcc-4e8a-917c-fe546bb37ad1-902893a3-a810-4b15-985e-3ccad3aea1c7"
  overwrite = true
  
  tags {
    Name = "Parameter Store: Infrastructure configured Gov Notify API Key"
    CCSRole = "Infrastructure"
  }
}
