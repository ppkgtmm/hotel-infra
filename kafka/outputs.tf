data "aws_msk_bootstrap_brokers" "kafka-servers" {
  cluster_arn = aws_msk_serverless_cluster.hotel-kafka.arn
}
output "kafka-server" {
  value = data.aws_msk_bootstrap_brokers.kafka-servers.bootstrap_brokers_tls
}
