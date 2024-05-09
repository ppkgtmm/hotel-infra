output "cloud_function_uri" {
  value = google_cloudfunctions2_function.connector.service_config[0].uri
}
