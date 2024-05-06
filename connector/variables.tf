variable "bucket-id" {
  type = string
}

variable "object-key" {
  default = "debezium-connector-postgres-2.6.1.Final-plugin.tar.gz"
}

variable "object-source" {
  default = "https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/2.6.1.Final/debezium-connector-postgres-2.6.1.Final-plugin.tar.gz"
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
