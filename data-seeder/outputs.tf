output "source_db_host" {
  value = google_sql_database_instance.hotel_instance.public_ip_address
}

output "source_db_connection" {
  value = google_sql_database_instance.hotel_instance.connection_name
}
