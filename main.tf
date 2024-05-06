terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.47.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "5.27.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
}

provider "aws" {
  region = var.aws-region
}

provider "random" {}

data "aws_caller_identity" "current" {}

module "data-generator" {
  source            = "./data-generator"
  aws-zone          = var.aws-zone
  aws-region        = var.aws-region
  account-id        = data.aws_caller_identity.current.account_id
  aws-ami           = var.aws-ami
  aws-instance-type = var.aws-instance-type
}

module "data-seeder" {
  source             = "./data-seeder"
  source-db-name     = var.source-db-name
  source-db-password = var.source-db-password
  source-db-username = var.source-db-username
  aws-zone           = var.aws-zone
  aws-region         = var.aws-region
  bucket-id          = module.data-generator.bucket-id
  aws-ami            = var.aws-ami
  aws-instance-type  = var.aws-instance-type
}

module "connector" {
  source            = "./connector"
  bucket-id         = module.data-generator.bucket-id
  aws-region        = var.aws-region
  aws-zone          = var.aws-zone
  aws-ami           = var.aws-ami
  aws-instance-type = var.aws-instance-type
}

module "kafka" {
  source = "./kafka"
}
