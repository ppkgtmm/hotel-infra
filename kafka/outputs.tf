output "kafka-server" {
  value = aws_msk_cluster.hotel-kafka.bootstrap_brokers_tls
}
