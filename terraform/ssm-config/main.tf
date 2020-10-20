terraform {
  required_version = "~> 0.11"
}

resource "aws_ssm_parameter" "global_google_geocoding_api_key" {
	name = "/Environment/global/GOOGLE_GEOCODING_API_KEY"
	type = "SecureString"
	value = "redacted"
}

resource "aws_ssm_parameter" "global_http_basic_auth_name" {
	name = "/Environment/global/HTTP_BASIC_AUTH_NAME"
	type = "SecureString"
	value = "redacted"
}

resource "aws_ssm_parameter" "global_http_basic_auth_password" {
	name = "/Environment/global/HTTP_BASIC_AUTH_PASSWORD"
	type = "SecureString"
	value = "redacted"
}

resource "aws_ssm_parameter" "global_dfe_signin_client_id" {
	name = "/Environment/global/DFE_SIGNIN_CLIENT_ID"
	type = "SecureString"
	value = "redacted"
}

resource "aws_ssm_parameter" "global_dfe_signin_client_secret" {
	name = "/Environment/global/DFE_SIGNIN_CLIENT_SECRET"
	type = "SecureString"
	value = "redacted"
}

resource "aws_ssm_parameter" "global_dfe_signin_url" {
	name = "/Environment/global/DFE_SIGNIN_URL"
	type = "SecureString"
	value = "https://signin-test-oidc-as.azurewebsites.net"
}

resource "aws_ssm_parameter" "global_dfe_signin_redirect_uri" {
	name = "/Environment/global/DFE_SIGNIN_REDIRECT_URI"
	type = "SecureString"
	value = "https://cmp.cmpdev.crowncommercial.gov.uk/auth/dfe/callback"
}

resource "aws_ssm_parameter" "global_supply_teachers_cognito_enabled" {
	name = "/Environment/global/SUPPLY_TEACHERS_COGNITO_ENABLED"
	type = "SecureString"
	value = "TRUE"
}

resource "aws_ssm_parameter" "global_ga_tracking_id" {
	name = "/Environment/global/GA_TRACKING_ID"
	type = "SecureString"
	value = "redacted"
}

resource "aws_ssm_parameter" "global_secret_key_base" {
	name = "/Environment/global/SECRET_KEY_BASE"
	type = "SecureString"
	value = "redacted"
}

resource "aws_ssm_parameter" "global_rollbar_access_token" {
	name = "/Environment/global/ROLLBAR_ACCESS_TOKEN"
	type = "SecureString"
	value = "redacted"
}

resource "aws_ssm_parameter" "global_rollbar_env" {
	name = "/Environment/global/ROLLBAR_ENV"
	type = "SecureString"
	value = "CMPDEV"
}

resource "aws_ssm_parameter" "global_feedback_email_address" {
	name = "/Environment/global/FEEDBACK_EMAIL_ADDRESS"
	type = "SecureString"
	value = "redacted@crowncommercial.gov.uk"
}

resource "aws_ssm_parameter" "global_gov_notify_api_key" {
	name = "/Environment/global/GOV_NOTIFY_API_KEY"
	type = "SecureString"
	value = "redacted"
}

resource "aws_ssm_parameter" "cmp_log_level" {
	name = "/Environment/ccs/cmp/LOG_LEVEL"
	type = "SecureString"
	value = "debug"
}

resource "aws_ssm_parameter" "cmpsidekeq_cmpsidekiq_log_level" {
	name = "/Environment/ccs/cmpsidekiq/LOG_LEVEL"
	type = "SecureString"
	value = "debug"
}

resource "aws_ssm_parameter" "cmp_app_run_email_replacement" {
	name = "/Environment/ccs/cmp/APP_RUN_EMAIL_REPLACEMENT"
	type = "SecureString"
	value = "FALSE"
}

resource "aws_ssm_parameter" "cmp_app_run_procurements_cleanup" {
	name = "/Environment/ccs/cmp/APP_RUN_PROCUREMENTS_CLEANUP"
	type = "SecureString"
	value = "FALSE"
}

resource "aws_ssm_parameter" "cmp_app_run_nuts_import" {
	name = "/Environment/ccs/cmp/APP_RUN_NUTS_IMPORT"
	type = "SecureString"
	value = "FALSE"
}

resource "aws_ssm_parameter" "cmp_app_run_postcodes_import" {
	name = "/Environment/ccs/cmp/APP_RUN_POSTCODES_IMPORT"
	type = "SecureString"
	value = "FALSE"
}

resource "aws_ssm_parameter" "cmp_ccs_app_api_data_bucket" {
	name = "/Environment/ccs/cmp/CCS_APP_API_DATA_BUCKET"
	type = "SecureString"
	value = "ccs.redacted.production.app-api-data"
}

resource "aws_ssm_parameter" "cmp_app_update_nuts_now" {
	name = "/Environment/ccs/cmp/APP_UPDATE_NUTS_NOW"
	type = "SecureString"
	value = "FALSE"
}

resource "aws_ssm_parameter" "cmp_buyer_email_safe_list_bucket" {
	name = "/Environment/ccs/cmp/BUYER_EMAIL_SAFE_LIST_BUCKET"
	type = "SecureString"
	value = "ccs.414753715227.postcode-data"
}

resource "aws_ssm_parameter" "cmp_buyer_email_safe_list_key" {
	name = "/Environment/ccs/cmp/BUYER_EMAIL_SAFE_LIST_KEY"
	type = "SecureString"
	value = "buyerSafelist/production/buyer-email-domains.txt"
}

resource "aws_ssm_parameter" "cmp_test_email_templates_api_token" {
	name = "/Environment/ccs/cmp/TEST_EMAIL_TEMPLATES_API_TOKEN"
	type = "SecureString"
	value = "redacted"
}

resource "aws_ssm_parameter" "cmplegacy_log_level" {
	name = "/Environment/ccs/cmp-legacy/LOG_LEVEL"
	type = "SecureString"
	value = "debug"
}

resource "aws_ssm_parameter" "cmplegacy_app_run_email_replacement" {
	name = "/Environment/ccs/cmp-legacy/APP_RUN_EMAIL_REPLACEMENT"
	type = "SecureString"
	value = "FALSE"
}

resource "aws_ssm_parameter" "cmplegacy_app_run_procurements_cleanup" {
	name = "/Environment/ccs/cmp-legacy/APP_RUN_PROCUREMENTS_CLEANUP"
	type = "SecureString"
	value = "FALSE"
}

resource "aws_ssm_parameter" "cmplegacy_app_run_nuts_import" {
	name = "/Environment/ccs/cmp-legacy/APP_RUN_NUTS_IMPORT"
	type = "SecureString"
	value = "FALSE"
}

resource "aws_ssm_parameter" "cmplegacy_app_run_postcodes_import" {
	name = "/Environment/ccs/cmp-legacy/APP_RUN_POSTCODES_IMPORT"
	type = "SecureString"
	value = "FALSE"
}

resource "aws_ssm_parameter" "cmplegacy_ccs_app_api_data_bucket" {
	name = "/Environment/ccs/cmp-legacy/CCS_APP_API_DATA_BUCKET"
	type = "SecureString"
	value = "ccs.redacted.production.app-api-data"
}

resource "aws_ssm_parameter" "cmplegacy_app_update_nuts_now" {
	name = "/Environment/ccs/cmp-legacy/APP_UPDATE_NUTS_NOW"
	type = "SecureString"
	value = "FALSE"
}

resource "aws_ssm_parameter" "cmplegacy_buyer_email_safe_list_bucket" {
	name = "/Environment/ccs/cmp-legacy/BUYER_EMAIL_SAFE_LIST_BUCKET"
	type = "SecureString"
	value = "ccs.414753715227.postcode-data"
}

resource "aws_ssm_parameter" "cmplegacy_buyer_email_safe_list_key" {
	name = "/Environment/ccs/cmp-legacy/BUYER_EMAIL_SAFE_LIST_KEY"
	type = "SecureString"
	value = "buyerSafelist/production/buyer-email-domains.txt"
}

resource "aws_ssm_parameter" "cmplegacy_test_email_templates_api_token" {
	name = "/Environment/ccs/cmp-legacy/TEST_EMAIL_TEMPLATES_API_TOKEN"
	type = "SecureString"
	value = "redacted"
}

resource "aws_ssm_parameter" "cmplegacy_app_run_pc_table_migration" {
	name = "/Environment/ccs/cmp-legacy/APP_RUN_PC_TABLE_MIGRATION"
	type = "SecureString"
	value = "FALSE"
}

resource "aws_ssm_parameter" "cmplegacy_app_run_sidekiq" {
	name = "/Environment/ccs/cmp-legacy/APP_RUN_SIDEKIQ"
	type = "SecureString"
	value = "FALSE"
}

resource "aws_ssm_parameter" "cmplegacy_app_run_static_task" {
	name = "/Environment/ccs/cmp-legacy/APP_RUN_STATIC_TASK"
	type = "SecureString"
	value = "FALSE"
}

resource "aws_ssm_parameter" "cmplegacy_direct_award_data_key" {
	name = "/Environment/ccs/cmp-legacy/DIRECT_AWARD_DATA_KEY"
	type = "SecureString"
	value = "facilities_management/data/static/RM3830_Direct_Award_Data_dev_and_test.xlsx"
}

resource "aws_ssm_parameter" "cmplegacy_json_supplier_data_key" {
	name = "/Environment/ccs/cmp-legacy/JSON_SUPPLIER_DATA_KEY"
	type = "SecureString"
	value = "facilities_management/data/static/dummy_supplier_data.json"
}

resource "aws_ssm_parameter" "cmplegacy_rails_env_url" {
	name = "/Environment/ccs/cmp-legacy/RAILS_ENV_URL"
	type = "SecureString"
	value = "https://cmp.cmp-production.crowncommercial.gov.uk"
}

resource "aws_ssm_parameter" "cmplegacy_supplier_details_data_key" {
	name = "/Environment/ccs/cmp-legacy/SUPPLIER_DETAILS_DATA_KEY"
	type = "SecureString"
	value = "facilities_management/data/static/RM3830_Suppliers_Details_for_dev_and_test.xlsx"
}

resource "aws_ssm_parameter" "app_run_precompile_assets" {
	name = "/Environment/global/APP_RUN_PRECOMPILE_ASSETS"
	type = "SecureString"
	value = "TRUE"
}
