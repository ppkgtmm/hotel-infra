variable "google_cloud_region" {
  default = "us-central1"
}

variable "google_cloud_zone" {
  default = "us-central1-a"
}

variable "google_cloud_project" {
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
