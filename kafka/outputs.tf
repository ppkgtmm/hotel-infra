output "kafka-bootstrap-servers" {
  value = join(",", formatlist("%s:9092", values(var.kafka-bootstrap-servers)))
}
