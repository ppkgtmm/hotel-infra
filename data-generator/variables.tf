variable "aws_region" {
  type = string
}

variable "aws_zone" {
  type = string
}

variable "data-generator-role" {
  default = "s3-access"
}

variable "account-id" {
  type = string
}

variable "aws-ami" {
  type = string
}
