resource "google_compute_instance" "kafka-connect" {
  machine_type   = "e2-micro"
  name           = "kafka-connect"
  enable_display = false
  tags           = ["kafka-connect"]
  boot_disk {
    initialize_params {
      image = var.gcp-disk-image
      size  = 10
      type  = "pd-standard"
    }
  }
  network_interface {
    network = var.gcp-network
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
export KAFKA_SERVER=${var.kafka-server}
${file("./kafka-connect/setup.sh")}
EOF
}

resource "google_compute_firewall" "name" {
  network     = var.gcp-network
  name        = "allow-kafka-internal"
  target_tags = ["kafka"]
  source_tags = ["kafka-connect"]
  allow {
    protocol = "tcp"
    ports    = ["9092"]
  }
}