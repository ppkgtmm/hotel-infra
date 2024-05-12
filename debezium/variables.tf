variable "aws_ami" {
  type = string
}

variable "aws_zone" {
  type = string
}

variable "aws_instance_type" {
  type = string
}

variable "source_db_host" {
  type = string
}

variable "source_db_port" {
  type = string
}

variable "replication_user" {
  type      = string
  sensitive = true
}

variable "replication_password" {
  type      = string
  sensitive = true
}

variable "source_db_name" {
  type = string
}
