provider "aws" {
  version = "~> 2.70"
  region = "${var.region}"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

provider "archive" {
  version = "~> 1.3"
}

provider "random" {
  version = "~> 2.3"
}
