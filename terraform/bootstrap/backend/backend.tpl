terraform {
  backend "s3" {
    bucket         = "${bucket}"
    key            = "${component}"
    region         = "${region}"
    dynamodb_table = "terraform_state_lock"
  }
}
