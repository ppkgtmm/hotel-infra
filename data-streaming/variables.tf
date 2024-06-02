variable "google_cloud_project" {
  type = string
}

variable "google_cloud_region" {
  type = string
}

variable "google_cloud_zone" {
  type = string
}

variable "google_cloud_bucket" {
  type = string
}

variable "terraform_service_account" {
  type = string
}

variable "source_db_host" {
  type = string
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

variable "source_db_name" {
  default = "hotel"
}

variable "debezium_ip_address" {
  type = string
}

variable "source_db_connection" {
  type = string
}

variable "temp_bq_dataset" {
  type = string
}
