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

variable "s3-bucket-name" {
  type = string
}

variable "plugin-path" {
  default = "plugin/debezium-connector-postgres-2.6.1.zip"
}
