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
