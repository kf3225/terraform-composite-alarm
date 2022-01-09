terraform {
  required_version = "1.1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.24.0"
    }
  }
  backend "s3" {
    bucket  = "test-terraform-bucket-ap-northeast-1"
    key     = "dev.tfstate"
    region  = "ap-northeast-1"
    profile = "default"
  }
}
provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}
