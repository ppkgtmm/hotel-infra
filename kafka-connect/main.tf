resource "google_compute_instance" "kafka-connect" {
  machine_type   = "e2-micro"
  name           = "kafka-connect"
  enable_display = false
  tags           = ["kafka-connect"]
  boot_disk {
    initialize_params {
      image = var.gcp_disk_image
      size  = 10
      type  = "pd-standard"
    }
  }
  network_interface {
    network = var.gcp_network
    access_config {
    }
  }
  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible         = true
    provisioning_model  = "SPOT"
  }
  metadata_startup_script = <<EOF
#!/bin/bash
export KAFKA_SERVERS=${var.kafka_bootstrap_servers}
export DB_NAME=${var.source_db_name}
export DB_HOST=${var.source_db_host}
export DB_PORT=${var.source_db_port}
export DB_USER=${var.source_db_username}
export DB_PASSWORD=${var.source_db_password}
export DBZ_USER=${var.replication_user}
export DBZ_PASSWORD=${var.replication_password}
${file("./kafka-connect/setup.sh")}
EOF
}

resource "google_compute_firewall" "name" {
  network     = var.gcp_network
  name        = "allow-kafka-internal"
  target_tags = ["kafka"]
  source_tags = ["kafka-connect"]
  allow {
    protocol = "tcp"
    ports    = ["9092"]
  }
}
