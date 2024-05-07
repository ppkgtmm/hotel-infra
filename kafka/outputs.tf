output "kafka_bootstrap_servers" {
  value = join(",", formatlist("%s:9092", values(var.kafka_bootstrap_servers)))
}
