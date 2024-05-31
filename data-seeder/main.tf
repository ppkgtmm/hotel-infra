resource "google_sql_database_instance" "hotel_instance" {
  database_version = "POSTGRES_15"
  region           = var.google_cloud_region
  name             = "hotel-db-instance"
  settings {
    tier              = "e2-micro"
    edition           = "ENTERPRISE"
    disk_size         = 10
    disk_autoresize   = false
    availability_type = "ZONAL"
    data_cache_config {
      data_cache_enabled = false
    }
    deletion_protection_enabled = false
    ip_configuration {
      ipv4_enabled = true
    }
    backup_configuration {
      enabled                        = false
      binary_log_enabled             = true
      point_in_time_recovery_enabled = false
    }
  }
}

resource "google_sql_database" "hotel_db" {
  instance = google_sql_database_instance.hotel_instance.name
  name     = var.source_db_name
}

resource "google_sql_user" "hotel_user" {
  instance = google_sql_database_instance.hotel_instance.name
  name     = var.source_db_username
  password = var.source_db_password
}
