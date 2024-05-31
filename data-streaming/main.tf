locals {
  debezium_server_variables = {
    GCP_PROJECT_ID = var.google_cloud_project
    DB_HOST        = var.source_db_host
    DB_USER        = var.replication_username
    DB_PASSWORD    = var.replication_password
    DB_NAME        = var.source_db_name
    ROOT_PASSWORD  = var.source_db_password
  }
}

resource "google_compute_instance" "debezium" {
  name         = "debezium"
  machine_type = "e2-micro"
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
}
