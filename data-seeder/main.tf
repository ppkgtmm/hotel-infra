resource "google_sql_database_instance" "hotel_instance" {
  database_version = "POSTGRES_15"
  region           = var.google_cloud_region
  name             = "hotel-db-instance"
  settings {
    tier              = "db-g1-small"
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
    database_flags {
      name  = "cloudsql.logical_decoding"
      value = "on"
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
