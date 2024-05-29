variable "aws_region" {
  default = "ap-south-1"
}

variable "availability_zone" {
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

variable "ubuntu_ami" {
  default = "ami-05e00961530ae1b55"
}

variable "instance_type" {
  default = "t2.micro"
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

variable "seed_directory" {
  default = "seeds/"
}

variable "warehouse_db_name" {
  default = "hotel"
}

variable "warehouse_db_username" {
  type      = string
  sensitive = true
}

variable "warehouse_db_password" {
  type      = string
  sensitive = true
}
