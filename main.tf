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
  gcp_disk_type           = var.gcp_disk_type
  gcp_machine_type        = var.gcp_machine_type
  gcp_network             = var.gcp_network
  kafka_bootstrap_servers = module.kafka.kafka_bootstrap_servers
  source_db_host          = module.data_seeder.source_db_host
  source_db_port          = module.data_seeder.source_db_port
  source_db_username      = var.source_db_username
  source_db_password      = var.source_db_password
  source_db_name          = var.source_db_name
  replication_user        = var.replication_user
  replication_password    = var.replication_password
  depends_on              = [module.kafka]
}

resource "aws_security_group_rule" "allow_kafka_connect" {
  security_group_id = data.aws_security_group.default.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = module.data_seeder.source_db_port
  to_port           = module.data_seeder.source_db_port
  cidr_blocks       = ["${module.kafka_connect.kafka_connect_ip}/32"]
}
