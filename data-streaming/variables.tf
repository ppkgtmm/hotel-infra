variable "availability_zone" {
  default = "ap-south-1a"
}

variable "source_db_name" {
  default = "hotel"
}

variable "source_db_host" {
  type = string
}

variable "source_db_port" {
  type = string
}

variable "source_db_username" {
  type      = string
  sensitive = true
}

variable "source_db_password" {
  type      = string
  sensitive = true
}

variable "ubuntu_ami" {
  default = "ami-05e00961530ae1b55"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "replication_user" {
  type      = string
  sensitive = true
}

variable "replication_password" {
  type      = string
  sensitive = true
}

variable "s3_bucket_name" {
  type = string
}

variable "security_groups" {
  type = set(string)
}

variable "client_subnets" {
  type = set(string)
}

variable "bootstrap_brokers" {
  type = string
}
