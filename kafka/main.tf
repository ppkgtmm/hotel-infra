resource "random_uuid" "rand" {}

resource "google_compute_instance" "kafka" {
  machine_type   = "e2-micro"
  name           = "kafka"
  enable_display = false
  boot_disk {
    initialize_params {
      image = var.gcp-disk-image
      size  = 10
      type  = "pd-standard"
    }
  }
  tags = ["kafka"]
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
export KAFKA_CLUSTER_ID=${random_uuid.rand.id}
${file("./kafka/setup.sh")}
EOF
}
