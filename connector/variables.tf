variable "bucket-id" {
  type = string
}

variable "plugin" {
  default = "debezium-connector-postgres-2.6.1"
}

variable "aws-region" {
  type = string
}

variable "aws-zone" {
  type = string
}

variable "aws-ami" {
  type = string
}

variable "aws-instance-type" {
  type = string
}

variable "connector-role" {
  default = "s3-access"
}
