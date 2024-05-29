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
