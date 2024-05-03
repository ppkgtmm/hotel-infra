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

# data "aws_caller_identity" "current" {}

# data "aws_vpc" "default" {
#   default = true
# }

# data "aws_security_group" "default" {
#   vpc_id = data.aws_vpc.default.id
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_postgres" {
#   security_group_id = data.aws_security_group.default.id
#   ip_protocol       = "tcp"
#   cidr_ipv4         = data.google_compute_network.default.gateway_ipv4
#   from_port         = 5432
#   to_port           = 5432
# }
