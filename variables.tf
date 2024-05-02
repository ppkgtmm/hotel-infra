variable "region" {
  default = "ap-southeast-1"
}

variable "data-generator-role" {
  default = "s3-access"
}

variable "data-seeder-role" {
  default = "rds-s3-access"
}

variable "source-db-name" {
  default = "oltp_hotel"
}

variable "source-db-username" {
  type      = string
  sensitive = true
}

variable "source-db-password" {
  type      = string
  sensitive = true
}
