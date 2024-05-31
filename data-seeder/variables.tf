variable "google_cloud_region" {
  type = string
}

variable "google_cloud_bucket" {
  type = string
}

variable "terraform_service_account" {
  type = string
}

variable "seed_directory" {
  type = string
}

variable "location_file" {
  type = string
}

variable "seed" {
  type = number
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

variable "debezium_ip_address" {
  type = string
}
