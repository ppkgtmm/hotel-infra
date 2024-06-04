resource "google_dataproc_cluster" "hotel_stream" {
  name   = "hotel-stream"
  region = var.google_cloud_region
  cluster_config {
    master_config {
      num_instances = 1
      machine_type  = "e2-small"
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 30
      }
    }
    worker_config {
      num_instances = 2
      machine_type  = "e2-small"
      disk_config {
        boot_disk_size_gb = 30
        boot_disk_type    = "pd-standard"
      }
    }
    gce_cluster_config {
      service_account        = var.terraform_service_account
      service_account_scopes = ["cloud-platform"]
    }
  }
}

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
      GCP_PROJECT_ID  = var.google_cloud_project
      GCP_REGION      = var.google_cloud_region
      GCP_ZONE        = var.google_cloud_zone
      SERVICE_ACCOUNT = var.terraform_service_account
      BUCKET_NAME     = var.google_cloud_bucket
      CLUSTER_NAME    = google_dataproc_cluster.hotel_stream.name
    }
    service_account_email = var.terraform_service_account
  }
}

data "google_service_account_id_token" "id_token" {
  target_audience        = google_cloudfunctions2_function.processor.url
  target_service_account = var.terraform_service_account
}

resource "null_resource" "trigger_processor" {
  provisioner "local-exec" {
    command = "curl -X POST $URL -H \"Authorization: bearer $TOKEN\" -H \"Content-Type: application/json\""
    environment = {
      TOKEN = data.google_service_account_id_token.id_token.id_token
      URL   = google_cloudfunctions2_function.processor.url
    }
  }
}
