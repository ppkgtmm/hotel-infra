output "kafka_bootstrap_servers" {
  value = data.aws_msk_bootstrap_brokers.kafka_brokers.bootstrap_brokers_sasl_iam
}
