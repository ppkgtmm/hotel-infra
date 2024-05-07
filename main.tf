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

provider "google" {
  project = var.gcp-project-id
  region  = var.gcp-region
  zone    = var.gcp-zone
}

provider "random" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
}

module "data-generator" {
  source              = "./data-generator"
  aws-zone            = var.aws-zone
  aws-region          = var.aws-region
  account-id          = data.aws_caller_identity.current.account_id
  aws-ami             = var.aws-ami
  aws-instance-type   = var.aws-instance-type
  data-generator-role = var.s3-role
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
  data-seeder-role   = var.rds-s3-role
  depends_on         = [module.data-generator]
}

module "connector" {
  source               = "./connector"
  bucket-id            = module.data-generator.bucket-id
  aws-region           = var.aws-region
  aws-zone             = var.aws-zone
  aws-ami              = var.aws-ami
  aws-instance-type    = var.aws-instance-type
  connector-role       = var.rds-s3-role
  source-db-host       = module.data-seeder.source-db-host
  source-db-port       = module.data-seeder.source-db-port
  source-db-user       = var.source-db-username
  source-db-password   = var.source-db-password
  source-db-name       = var.source-db-name
  replication-user     = var.replication-user
  replication-password = var.replication-password
  depends_on           = [module.data-seeder]
}

module "kafka" {
  source            = "./kafka"
  security-group-id = data.aws_security_group.default.id
  subnets           = data.aws_subnets.subnets.ids
}

module "kafka-connect" {
  source               = "./kafka-connect"
  security-group-id    = data.aws_security_group.default.id
  subnets              = data.aws_subnets.subnets.ids
  bucket-id            = module.data-generator.bucket-id
  kafka-servers        = module.kafka.kafka-bootstrap-servers
  plugin-path          = module.connector.plugin-path
  connect-role         = var.rds-s3-role
  source-db-host       = module.data-seeder.source-db-host
  source-db-port       = module.data-seeder.source-db-port
  replication-user     = var.replication-user
  replication-password = var.replication-password
  source-db-name       = var.source-db-name
  depends_on           = [module.kafka]
}
