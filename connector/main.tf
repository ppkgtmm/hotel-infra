resource "google_cloudfunctions2_function" "connector" {
  name     = "register-connector"
  location = var.gcp_region
  build_config {
    runtime     = "python312"
    entry_point = "register_source_database"
    source {
      storage_source {
        bucket = var.gcp_bucket_name
        object = var.function_zip_file
      }
    }
  }
  service_config {
    max_instance_count    = 1
    environment_variables = { DB_HOST : var.source_db_host, DBZ_USER : var.replication_user, DBZ_PASSWORD : var.replication_password, DB_NAME : var.source_db_name, KAFKA_CONNECT_SERVER : var.kafka_connect_server }
  }
}

resource "google_cloud_run_service_iam_member" "member" {
  location = google_cloudfunctions2_function.connector.location
  service  = google_cloudfunctions2_function.connector.name
  role     = "roles/run.invoker"
  member   = "allAuthenticatedUsers"
}
