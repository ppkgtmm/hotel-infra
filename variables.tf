variable "aws_region" {
  default = "ap-southeast-1"
}

variable "data-generator-role" {
  default = "s3-access"
}

variable "data-seeder-role" {
  default = "rds-s3-access"
}

variable "source-db-name" {
  default = "hotel"
}

variable "source-db-username" {
  type      = string
  sensitive = true
}

variable "source-db-password" {
  type      = string
  sensitive = true
}

variable "gcp-project-id" {
  type      = string
  sensitive = true
}

variable "gcp_region" {
  default = "us-central1"
}

variable "gcp_zone" {
  default = "us-central1-c"
}

variable "gcp_disk_image" {
  default = "ubuntu-2204-jammy-v20240501"
}
