variable "google_cloud_region" {
  default = "us-central1"
}

variable "google_cloud_zone" {
  default = "us-central1-a"
}

variable "google_cloud_project" {
  type = string
}

variable "terraform_service_account" {
  type = string
}

variable "google_cloud_bucket" {
  type = string
}

variable "seed" {
  default = 42
}

variable "seed_directory" {
  default = "seeds/"
}

variable "location_file" {
  default = "https://github.com/ppkgtmm/location/raw/main/states_provinces.csv"
}

variable "source_db_name" {
  default = "hotel"
}

variable "source_db_password" {
  type      = string
  sensitive = true
}

variable "replication_username" {
  type      = string
  sensitive = true
}

variable "replication_password" {
  type      = string
  sensitive = true
}
