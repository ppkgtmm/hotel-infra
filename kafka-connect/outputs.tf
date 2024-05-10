output "kafka_connect_ip" {
  value = aws_instance.kafka_connect.private_ip
}
