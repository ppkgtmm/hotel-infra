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
