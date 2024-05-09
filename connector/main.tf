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
  event_trigger {
    event_type   = "google.cloud.storage.object.v1.finalized"
    retry_policy = "RETRY_POLICY_RETRY"
    event_filters {
      attribute = "bucket"
      value     = var.gcp_bucket_name
    }
  }
}

resource "google_storage_bucket_object" "name" {
  name    = "trigger"
  content = "just to trigger cloud function"
  bucket  = var.gcp_bucket_name
}
