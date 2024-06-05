output "metabase_endpoint" {
  value = format("%s:%s", google_compute_instance.metabase.network_interface[0].access_config[0].nat_ip, "3000")
}
