data "aws_msk_bootstrap_brokers" "kafka" {
  cluster_arn = aws_msk_serverless_cluster.hotel-kafka.arn
}
output "kafka-servers" {
  value = data.aws_msk_bootstrap_brokers.kafka.bootstrap_brokers_sasl_iam
}
