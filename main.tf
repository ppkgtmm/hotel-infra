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
  project = var.gcp-project-id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

provider "random" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_postgres" {
  security_group_id = data.aws_security_group.default.id
  ip_protocol       = "tcp"
  cidr_ipv4         = "${google_compute_instance.kafka-connect.network_interface[0].access_config[0].nat_ip}/32"
  from_port         = 5432
  to_port           = 5432
}

module "data-generator" {
  source     = "./data-generator"
  aws_zone   = var.aws_zone
  aws_region = var.aws_region
  account-id = data.aws_caller_identity.current.account_id
}
module "data-seeder" {
  source             = "./data-seeder"
  source-db-name     = var.source-db-name
  source-db-password = var.source-db-password
  source-db-username = var.source-db-username
  aws_zone           = var.aws_zone
  aws_region         = var.aws_region
  bucket-id          = module.data-generator.bucket-id
}

module "kafka" {
  source         = "./kafka"
  gcp_network    = var.gcp_network
  gcp_disk_image = var.gcp_disk_image
}

module "kafka-connect" {
  source         = "./kafka-connect"
  gcp_network    = var.gcp_network
  gcp_disk_image = var.gcp_disk_image
  kafka_server   = module.kafka.kafka-server
}
