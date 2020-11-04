terraform {
  backend "s3" {
    bucket         = "ccs.538094434428.tfstate"
    key            = "infrastructure"
    region         = "eu-west-2"
    dynamodb_table = "terraform_state_lock"
  }
}
