variable "aws_ami" {
  type = string
}

variable "aws_zone" {
  type = string
}

variable "kafka_connect_role" {
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
