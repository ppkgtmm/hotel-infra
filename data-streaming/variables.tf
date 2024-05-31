variable "google_cloud_project" {
  type = string
}

variable "source_db_host" {
  type = string
}

variable "source_db_username" {
  type      = string
  sensitive = true
}

variable "source_db_password" {
  type      = string
  sensitive = true
}

variable "source_db_name" {
  default = "hotel"
}

variable "debezium_ip_address" {
  type = string
}
