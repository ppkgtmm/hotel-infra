variable "gcp_disk_image" {
  type = string
}

variable "gcp_network" {
  type = string
}

variable "gcp_disk_type" {
  type = string
}

variable "gcp_machine_type" {
  type = string
}

variable "kafka_bootstrap_servers" {
  type = string
}

variable "source_db_name" {
  default = "hotel"
}

variable "source_db_username" {
  type      = string
  sensitive = true
}

variable "source_db_password" {
  type      = string
  sensitive = true
}

variable "source_db_host" {
  type = string
}

variable "source_db_port" {
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
