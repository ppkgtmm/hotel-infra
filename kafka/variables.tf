variable "gcp-disk-image" {
  type = string
}

variable "gcp-disk-type" {
  type = string
}

variable "gcp-machine-type" {
  type = string
}

variable "gcp-network" {
  type = string
}

variable "kafka-bootstrap-servers" {
  default = ["kafka1", "kafka2", "kafka3"]
}
