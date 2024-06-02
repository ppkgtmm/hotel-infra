resource "google_cloudfunctions2_function" "processor" {
  name     = "hotel-processor"
  location = var.google_cloud_region
  build_config {
    runtime     = "python312"
    entry_point = "prepare_and_process"
    source {
      storage_source {
        bucket = var.google_cloud_bucket
        object = "hotel-processor.zip"
      }
    }
  }
  service_config {
    min_instance_count = 1
    max_instance_count = 1
    timeout_seconds    = 300
    environment_variables = {
      GCP_PROJECT_ID = var.google_cloud_project
    }
    service_account_email = var.terraform_service_account
  }
}

data "google_service_account_id_token" "id_token" {
  target_audience        = google_cloudfunctions2_function.processor.url
  target_service_account = var.terraform_service_account
}

resource "null_resource" "trigger_connector" {
  provisioner "local-exec" {
    command = "curl -X POST $URL -H \"Authorization: bearer $TOKEN\" -H \"Content-Type: application/json\""
    environment = {
      TOKEN = data.google_service_account_id_token.id_token.id_token
      URL   = google_cloudfunctions2_function.processor.url
    }
  }
}
