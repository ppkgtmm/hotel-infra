variable "aws_security_group" {
  type = string
}

variable "aws_subnets" {
  type = set(string)
}
