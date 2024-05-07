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
  region = var.aws_region
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
}

module "data_generator" {
  source              = "./data-generator"
  aws_zone            = var.aws_zone
  aws_region          = var.aws_region
  account_id          = data.aws_caller_identity.current.account_id
  aws_ami             = var.aws_ami
  aws_instance_type   = var.aws_instance_type
  data_generator_role = var.s3_role
  s3_bucket_name      = var.s3_bucket_name
}

module "data_seeder" {
  source             = "./data-seeder"
  source_db_name     = var.source_db_name
  source_db_password = var.source_db_password
  source_db_username = var.source_db_username
  aws_zone           = var.aws_zone
  aws_region         = var.aws_region
  s3_bucket_name     = var.s3_bucket_name
  aws_ami            = var.aws_ami
  aws_instance_type  = var.aws_instance_type
  data_seeder_role   = var.rds_s3_role
  depends_on         = [module.data_generator]
}

# module "connector" {
#   source               = "./connector"
#   aws-zone             = var.aws-zone
#   aws-ami              = var.aws-ami
#   aws-instance-type    = var.aws-instance-type
#   connector-role       = var.rds-s3-role
#   source-db-host       = module.data-seeder.source-db-host
#   source-db-port       = module.data-seeder.source-db-port
#   source-db-user       = var.source-db-username
#   source-db-password   = var.source-db-password
#   source-db-name       = var.source-db-name
#   replication-user     = var.replication-user
#   replication-password = var.replication-password
#   depends_on           = [module.data-seeder]
# }

module "kafka" {
  source           = "./kafka"
  gcp_machine_type = var.gcp_machine_type
  gcp_disk_type    = var.gcp_disk_type
  gcp_network      = var.gcp_network
  gcp_disk_image   = var.gcp_disk_image
  depends_on       = [module.data_seeder]
}

module "kafka_connect" {
  source                  = "./kafka-connect"
  gcp_disk_image          = var.gcp_disk_image
  gcp_network             = var.gcp_network
  kafka_bootstrap_servers = module.kafka.kafka_bootstrap_servers
  depends_on              = [module.kafka]
}
