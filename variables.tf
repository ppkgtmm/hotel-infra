variable "aws-region" {
  default = "ap-south-1"
}

variable "aws-zone" {
  default = "ap-south-1c"
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
  default = "ami-072b1c33a2439c226"
}

variable "aws-instance-type" {
  default = "t2.micro"
}
