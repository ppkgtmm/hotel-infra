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

variable "kafka_connect_role" {
  default = "kafka-access"
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

variable "connector_role" {
  default = "s3-ec2-access"

}
variable "gcp_project_id" {
  type      = string
  sensitive = true
}

variable "gcp_region" {
  default = "us-central1"
}

variable "gcp_zone" {
  default = "us-central1-a"
}

variable "gcp_disk_image" {
  default = "ubuntu-2204-jammy-v20240501"
}

variable "gcp_network" {
  default = "default"
}

variable "gcp_disk_type" {
  default = "pd-standard"
}

variable "gcp_machine_type" {
  default = "e2-micro"
}

variable "gcp_bucket_name" {
  type = string
}
