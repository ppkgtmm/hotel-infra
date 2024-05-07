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
  type = string
}

variable "source-db-host" {
  type = string
}

variable "source-db-port" {
  type = string
}

variable "source-db-user" {
  type      = string
  sensitive = true
}

variable "source-db-password" {
  type      = string
  sensitive = true
}

variable "source-db-name" {
  type = string
}

variable "replication-user" {
  type      = string
  sensitive = true
}

variable "replication-password" {
  type      = string
  sensitive = true
}
