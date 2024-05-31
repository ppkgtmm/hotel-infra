resource "google_sql_database_instance" "hotel_instance" {
  database_version    = "POSTGRES_15"
  region              = var.google_cloud_region
  name                = "hotel-db-instance"
  deletion_protection = false
  root_password       = var.source_db_password
  settings {
    tier              = "db-g1-small"
    edition           = "ENTERPRISE"
    disk_size         = 10
    disk_autoresize   = false
    availability_type = "ZONAL"
    data_cache_config {
      data_cache_enabled = false
    }
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "replication"
        value = "${var.debezium_ip_address}/32"
      }
    }
    database_flags {
      name  = "cloudsql.logical_decoding"
      value = "on"
    }
    backup_configuration {
      enabled = false
    }
  }
}

resource "google_sql_database" "hotel_db" {
  instance   = google_sql_database_instance.hotel_instance.name
  name       = var.source_db_name
  depends_on = [google_sql_user.hotel_user]
}

resource "google_sql_user" "hotel_user" {
  instance = google_sql_database_instance.hotel_instance.name
  name     = var.replication_username
  password = var.replication_password
}

resource "google_cloudfunctions2_function" "dataseed" {
  location = var.google_cloud_region
  name     = "hotel-dataseed"
  build_config {
    runtime     = "python312"
    entry_point = "populate_source_db"
    source {
      storage_source {
        bucket = var.google_cloud_bucket
        object = "hotel-dataseed.zip"
      }
    }
  }
  service_config {
    min_instance_count = 1
    max_instance_count = 1
    timeout_seconds    = 300
    environment_variables = {
      LOCATION_FILE = var.location_file
      SEED          = var.seed
      SEED_DIR      = var.seed_directory
      GCS_BUCKET    = var.google_cloud_bucket
      CONNECTION    = google_sql_database_instance.hotel_instance.connection_name
      DB_USER       = var.replication_username
      DB_PASSWORD   = var.replication_password
      DB_NAME       = var.source_db_name
    }
  }
}

data "google_service_account_id_token" "id_token" {
  target_audience        = google_cloudfunctions2_function.dataseed.url
  target_service_account = var.terraform_service_account
}

resource "null_resource" "trigger_dataseed" {
  provisioner "local-exec" {
    command = "curl -X POST $URL -H \"Authorization: bearer $TOKEN\" -H \"Content-Type: application/json\""
    environment = {
      TOKEN = data.google_service_account_id_token.id_token.id_token
      URL   = google_cloudfunctions2_function.dataseed.url
    }
  }
  depends_on = [google_sql_user.hotel_user]
}
