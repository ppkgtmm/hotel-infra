variable "aws_region" {
  type = string
}

variable "availability_zone" {
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

variable "ubuntu_ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "seed_directory" {
  type = string
}
