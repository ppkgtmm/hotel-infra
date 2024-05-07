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
  default = { 1 : "kafka1", 2 : "kafka2", 3 : "kafka3" }
  type    = map
}
