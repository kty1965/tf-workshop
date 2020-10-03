# terraform backend need to use static arguments.
terraform {
  backend "s3" {
    bucket         = "tf-state.example.com"
    key            = "main.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "tf-state.example.com"
  }
  required_version = ">= 0.13"
}