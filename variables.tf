variable "aws_region" {
  default = "ap-south-1"
}

variable "aws_zone" {
  default = "ap-south-1a"
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

variable "aws_ami" {
  default = "ami-05e00961530ae1b55"
}

variable "aws_instance_type" {
  default = "t2.micro"
}

variable "rds_s3_role" {
  default = "rds-s3-access"
}

variable "s3_role" {
  default = "s3-access"
}

variable "replication_user" {
  type      = string
  sensitive = true
}

variable "replication_password" {
  type      = string
  sensitive = true
}

variable "s3_bucket_name" {
  type = string
}

variable "plugin_path" {
  default = "plugin/debezium-connector-postgres.zip"
}
