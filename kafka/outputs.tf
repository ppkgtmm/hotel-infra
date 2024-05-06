output "kafka-bootstrap-servers" {
  value = aws_msk_cluster.hotel-kafka.bootstrap_brokers_tls
}
