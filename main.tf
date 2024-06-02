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

module "data_generator" {
  source                    = "./data-generator"
  location_file             = var.location_file
  seed                      = var.seed
  seed_directory            = var.seed_directory
  google_cloud_region       = var.google_cloud_region
  google_cloud_bucket       = var.google_cloud_bucket
  terraform_service_account = var.terraform_service_account
}

module "data_seeder" {
  source                    = "./data-seeder"
  google_cloud_region       = var.google_cloud_region
  source_db_password        = var.source_db_password
  replication_username      = var.replication_username
  replication_password      = var.replication_password
  terraform_service_account = var.terraform_service_account
  google_cloud_bucket       = var.google_cloud_bucket
  location_file             = var.location_file
  seed                      = var.seed
  seed_directory            = var.seed_directory
  debezium_ip_address       = google_compute_address.debezium_ip.address
  depends_on                = [module.data_generator]
}

module "data_streaming" {
  source                    = "./data-streaming"
  source_db_connection      = module.data_seeder.source_db_connection
  source_db_host            = module.data_seeder.source_db_host
  source_db_password        = var.source_db_password
  replication_username      = var.replication_username
  replication_password      = var.replication_password
  source_db_name            = var.source_db_name
  google_cloud_region       = var.google_cloud_region
  google_cloud_zone         = var.google_cloud_zone
  google_cloud_project      = var.google_cloud_project
  google_cloud_bucket       = var.google_cloud_bucket
  terraform_service_account = var.terraform_service_account
  debezium_ip_address       = google_compute_address.debezium_ip.address
  temp_bq_dataset           = var.temp_bq_dataset
  depends_on                = [module.data_seeder]
}
