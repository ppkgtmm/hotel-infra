variable "aws-region" {
  default = "ap-south-1"
}

variable "aws-zone" {
  default = "ap-south-1a"
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

variable "aws-ami" {
  default = "ami-05e00961530ae1b55"
}

variable "aws-instance-type" {
  default = "t2.micro"
}

variable "rds-s3-role" {
  default = "rds-s3-access"
}

variable "s3-role" {
  default = "s3-access"
}

variable "replication-user" {
  type      = string
  sensitive = true
}

variable "replication-password" {
  type      = string
  sensitive = true
}

variable "gcp-project-id" {
  type      = string
  sensitive = true
}

variable "gcp-region" {
  default = "us-central1"
}

variable "gcp-zone" {
  default = "us-central1-a"
}

variable "gcp-disk-image" {
  default = "ubuntu-2204-jammy-v20240501"
}

variable "gcp-network" {
  default = "default"
}

variable "gcp-disk-type" {
  default = "pd-standard"
}

variable "gcp-machine-type" {
  default = "e2-micro"
}
