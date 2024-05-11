variable "s3_bucket_name" {
  type = string
}

variable "connector_role" {
  type = string
}

variable "function_zip_file" {
  default = "hotel-connector.zip"
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

variable "source_db_address" {
  type = string
}

variable "source_db_port" {
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

variable "aws_security_group" {
  type = string
}

variable "aws_subnet_ids" {
  type = list(string)
}
