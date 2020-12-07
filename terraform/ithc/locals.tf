data "aws_caller_identity" "current" {}

locals {
  ithc_test_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.ithctests3bucket"
  s3_logging_bucket_name = "ccs.${data.aws_caller_identity.current.account_id}.s3.access-logs"
}
