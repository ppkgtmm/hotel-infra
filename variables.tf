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
