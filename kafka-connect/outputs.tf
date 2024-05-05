output "kafka-connect-ip" {
  value = google_compute_instance.kafka-connect.network_interface[0].access_config[0].nat_ip
}
