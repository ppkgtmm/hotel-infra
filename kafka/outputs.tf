output "kafka-bootstrap-servers" {
  value = data.aws_msk_bootstrap_brokers.kafka-servers.bootstrap_brokers_tls
}
