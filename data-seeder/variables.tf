variable "aws_region" {
  type = string
}

variable "aws_zone" {
  type = string
}

variable "data-seeder-role" {
  default = "rds-s3-access"
}

variable "source-db-name" {
  type = string
}

variable "source-db-username" {
  type      = string
  sensitive = true
}

variable "source-db-password" {
  type      = string
  sensitive = true
}

variable "bucket-id" {
  type = string
}

variable "aws-ami" {
  type = string
}
