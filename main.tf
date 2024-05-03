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

resource "random_uuid" "rand" {}

data "aws_vpc" "default" {
  default = true
resource "google_compute_address" "static" {
  name = "ipv4-address"
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
}

# data "google_compute_subnetwork" "default" {
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_postgres" {
#   security_group_id = data.aws_security_group.default.id
#   ip_protocol       = "tcp"
#   cidr_ipv4         = data.google_compute_network.default.gateway_ipv4
#   from_port         = 5432
#   to_port           = 5432
# }

output "aws_vpc" {
  value = data.aws_vpc.default.id
}

output "gcp_vpc" {
  value = data.google_compute_subnetwork.default.ip_cidr_range
}
