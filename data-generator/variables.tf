variable "aws_region" {
  type = string
}

variable "data_generator_role" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "function_zip_file" {
  default = "hotel-data-generator.zip"
}

variable "aws_security_group" {
  type = string
}

variable "aws_subnet_ids" {
  type = list(string)
}

variable "location_file" {
  type = string
}

variable "seed" {
  type = number
}

variable "seed_dir" {
  type = string
}
