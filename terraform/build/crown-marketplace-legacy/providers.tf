provider "aws" {
  version = "~> 2.70"
  region = "eu-west-2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}
