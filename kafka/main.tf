resource "aws_network_interface" "kafka_network_interface" {
  subnet_id         = var.aws_subnet_id
  private_ips_count = 3
  security_groups   = [var.aws_security_group]
}
