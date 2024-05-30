resource "google_cloudfunctions2_function" "datagen" {
  location = var.google_cloud_region
  name     = "hotel-datagen"
  build_config {
    runtime     = "python3.12"
    entry_point = "get_generated_data"
    source {
      storage_source {
        bucket = var.google_cloud_bucket
        object = "hotel-datagen.zip"
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
    }
  }
}
