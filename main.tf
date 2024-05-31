terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.31.1"
    }
  }
}

provider "google" {
  project = var.google_cloud_project
  region  = var.google_cloud_region
  zone    = var.google_cloud_zone
}

resource "google_compute_address" "debezium_ip" {
  name = "debezium-ip"
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
module "data_generator" {
  source                    = "./data-generator"
  location_file             = var.location_file
  seed                      = var.seed
  seed_directory            = var.seed_directory
  google_cloud_region       = var.google_cloud_region
  google_cloud_bucket       = var.google_cloud_bucket
  terraform_service_account = var.terraform_service_account
}
