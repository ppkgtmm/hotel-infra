variable "aws_region" {
  type = string
}

variable "aws_zone" {
  type = string
}

variable "data_seeder_role" {
  type = string
}

variable "source_db_name" {
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

variable "s3_bucket_name" {
  type = string
}

variable "aws_ami" {
  type = string
}

variable "aws_instance_type" {
  type = string
}
