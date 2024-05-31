resource "google_cloudfunctions2_function" "datagen" {
  location = var.google_cloud_region
  name     = "hotel-datagen"
  build_config {
    runtime     = "python312"
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

data "google_service_account_id_token" "id_token" {
  target_audience        = google_cloudfunctions2_function.datagen.url
  target_service_account = var.terraform_service_account
}

resource "null_resource" "trigger_datagen" {
  provisioner "local-exec" {
    command = "curl -X POST $URL -H \"Authorization: bearer $TOKEN\" -H \"Content-Type: application/json\""
    environment = {
      TOKEN = data.google_service_account_id_token.id_token.id_token
      URL   = google_cloudfunctions2_function.datagen.url
    }
  }
}
