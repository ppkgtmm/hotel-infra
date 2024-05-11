output "kafka_bootstrap_servers" {
  value = aws_msk_cluster.kafka.bootstrap_brokers_tls
}
