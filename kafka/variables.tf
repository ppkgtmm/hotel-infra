variable "gcp_disk_image" {
  type = string
}

variable "gcp_disk_type" {
  type = string
}

variable "gcp_machine_type" {
  type = string
}

variable "gcp_network" {
  type = string
}

variable "kafka_bootstrap_servers" {
  default = {
    1 : "kafka1"
    # , 2 : "kafka2" 
  }
  type = map
}
