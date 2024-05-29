terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.47.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
}

provider "aws" { region = var.aws_region }

provider "random" {}

data "aws_vpc" "default" { default = true }

data "aws_subnet" "default_subnet" {
  availability_zone = var.availability_zone
  default_for_az    = true
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

resource "aws_msk_cluster" "hotel_kafka" {
  number_of_broker_nodes = 1
  broker_node_group_info {
    instance_type   = var.instance_type
    security_groups = [data.aws_security_group.default.id]
    client_subnets  = [data.aws_subnet.default_subnet.id]
  }
  cluster_name  = "hotel-kafka"
  kafka_version = "3.5.1"
}

module "data_generator" {
  source            = "./data-generator"
  aws_region        = var.aws_region
  ubuntu_ami        = var.ubuntu_ami
  instance_type     = var.instance_type
  seed_directory    = var.seed_directory
  s3_bucket_name    = var.s3_bucket_name
  availability_zone = var.availability_zone
  depends_on        = [aws_msk_cluster.hotel_kafka]
}

module "data_seeder" {
  source             = "./data-seeder"
  aws_region         = var.aws_region
  seed_directory     = var.seed_directory
  s3_bucket_name     = var.s3_bucket_name
  availability_zone  = var.availability_zone
  instance_type      = var.instance_type
  ubuntu_ami         = var.ubuntu_ami
  source_db_name     = var.source_db_name
  source_db_username = var.source_db_username
  source_db_password = var.source_db_password
  depends_on         = [module.data_generator]
}

module "data_streaming" {
  source               = "./data-streaming"
  s3_bucket_name       = var.s3_bucket_name
  source_db_host       = module.data_seeder.source_db_host
  source_db_port       = module.data_seeder.source_db_port
  source_db_username   = var.source_db_username
  source_db_password   = var.source_db_password
  source_db_name       = var.source_db_name
  replication_user     = var.replication_user
  replication_password = var.replication_password
  client_subnets       = [data.aws_subnet.default_subnet.id]
  security_groups      = [data.aws_security_group.default.id]
  bootstrap_brokers    = aws_msk_cluster.hotel_kafka.bootstrap_brokers_tls
  depends_on           = [module.data_seeder]
}
