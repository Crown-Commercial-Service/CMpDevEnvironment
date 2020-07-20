provider "aws" {
  version = "~> 2.70"
  region = "${var.region}"
}

provider "local" {
  version = "~> 1.4"
}

provider "template" {
  version = "~> 2.1"
}
