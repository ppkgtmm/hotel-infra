variable "gcp_region" {
  type = string
}

variable "gcp_bucket_name" {
  type = string
}

variable "function_zip_file" {
  type = string
}

variable "source_db_host" {
  type = string
}

variable "kafka_connect_server" {
  type = string
}

variable "source_db_name" {
  type = string
}

variable "replication_user" {
  type      = string
  sensitive = true
}

variable "replication_password" {
  type      = string
  sensitive = true
}
