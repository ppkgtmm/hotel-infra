terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.47.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
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
  name   = "default"
}

module "data_generator" {
  source              = "./data-generator"
  aws_region          = var.aws_region
  data_generator_role = var.s3_ec2_role
  s3_bucket_name      = var.s3_bucket_name
  seed                = var.seed
  seed_dir            = var.seed_dir
  location_file       = var.location_file
  aws_security_group  = data.aws_security_group.default.id
  aws_subnet_ids      = data.aws_subnets.subnets.ids
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

module "connector" {
  source               = "./connector"
  aws_security_group   = data.aws_security_group.default.id
  aws_subnet_ids       = data.aws_subnets.subnets.ids
  connector_role       = var.s3_ec2_role
  s3_bucket_name       = var.s3_bucket_name
  source_db_address    = module.data_seeder.source_db_host
  source_db_username   = var.source_db_username
  source_db_password   = var.source_db_password
  source_db_name       = var.source_db_name
  replication_user     = var.replication_user
  replication_password = var.replication_password
  depends_on           = [module.data_seeder]
}

module "debezium" {
  source               = "./debezium"
  source_db_host       = module.data_seeder.source_db_host
  source_db_port       = module.data_seeder.source_db_port
  replication_user     = var.replication_user
  replication_password = var.replication_password
  source_db_name       = var.source_db_name
  aws_zone             = var.aws_zone
  aws_ami              = var.aws_ami
  aws_instance_type    = var.aws_instance_type
  kafka_server         = module.kafka.bootstrap_brokers_tls
  debezium_role        = var.sqs_role
  depends_on           = [module.connector]
}
