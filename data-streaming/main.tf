resource "google_cloudfunctions2_function" "connector" {
  location = var.google_cloud_region
  name     = "hotel-connector"
  build_config {
    runtime     = "python312"
    entry_point = "prepare_for_replication"
    source {
      storage_source {
        bucket = var.google_cloud_bucket
        object = "hotel-connector.zip"
      }
    }
  }
  service_config {
    min_instance_count = 1
    max_instance_count = 1
    timeout_seconds    = 300
    environment_variables = {
      CONNECTION     = var.source_db_connection
      ROOT_USER      = "postgres"
      ROOT_PASSWORD  = var.source_db_password
      DB_NAME        = var.source_db_name
      DB_USER        = var.replication_username
      GCP_PROJECT_ID = var.google_cloud_project
      GCP_REGION     = var.google_cloud_region
      GCP_ZONE       = split("-", var.google_cloud_zone)[2]
    }
    service_account_email = var.terraform_service_account
  }
}

data "google_service_account_id_token" "id_token" {
  target_audience        = google_cloudfunctions2_function.connector.url
  target_service_account = var.terraform_service_account
}

resource "null_resource" "trigger_connector" {
  provisioner "local-exec" {
    command = "curl -X POST $URL -H \"Authorization: bearer $TOKEN\" -H \"Content-Type: application/json\""
    environment = {
      TOKEN = data.google_service_account_id_token.id_token.id_token
      URL   = google_cloudfunctions2_function.connector.url
    }
  }
}

locals {
  debezium_server_variables = {
    GCP_PROJECT_ID = var.google_cloud_project
    DB_HOST        = var.source_db_host
    DB_USER        = var.replication_username
    DB_PASSWORD    = var.replication_password
    DB_NAME        = var.source_db_name
  }
}

resource "google_compute_instance" "debezium" {
  name         = "debezium"
  machine_type = "e2-micro"
  service_account {
    email  = var.terraform_service_account
    scopes = ["cloud-platform"]
  }
  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20240519"
    }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = var.debezium_ip_address
    }
  }
  metadata_startup_script = templatefile("data-streaming/debezium/initialize.sh", local.debezium_server_variables)
  depends_on              = [null_resource.trigger_connector]
}
