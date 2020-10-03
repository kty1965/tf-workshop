locals {
  account_id = "<AWS Account ID>"
}

provider "aws" {
  version                 = "~> 3.0"
  region                  = "ap-northeast-2"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "tf-admin"
  allowed_account_ids = [
    local.account_id
  ]
}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}