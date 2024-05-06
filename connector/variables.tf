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
  type = string
}

variable "source-db-host" {
  type = string
}

variable "source-db-port" {
  type = string
}

variable "source-db-user" {
  type = string
}

variable "source-db-password" {
  type = string
}

variable "source-db-name" {
  type = string
}

variable "replication-user" {
  type = string
}

variable "replication-password" {
  type = string
}
