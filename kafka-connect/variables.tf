variable "bucket-id" {
  type = string
}

variable "plugin-path" {
  type = string
}

variable "kafka-servers" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security-group-id" {
  type = string
}

variable "connect-role" {
  type = string
}

variable "source-db-host" {
  type = string
}

variable "source-db-port" {
  type = string
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