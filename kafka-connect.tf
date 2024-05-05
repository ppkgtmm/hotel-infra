resource "random_uuid" "rand" {}

resource "google_compute_address" "kafka" {
  name         = "kafka-ip-address"
  address_type = "INTERNAL"
  subnetwork   = var.gcp_network
  region       = var.gcp_region
}

resource "google_compute_instance" "kafka" {
  machine_type   = "e2-micro"
  name           = "kafka"
  enable_display = false
  boot_disk {
    initialize_params {
      image = var.gcp_disk_image
      size  = 10
      type  = "pd-standard"
    }
  }
  network_interface {
    network    = var.gcp_network
    network_ip = google_compute_address.kafka.address
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
export KAFKA_SERVER=${google_compute_address.kafka.address}
${file("./kafka/setup.sh")}
EOF
}

resource "google_compute_instance" "kafka-connect" {
  machine_type   = "e2-micro"
  name           = "kafka-connect"
  enable_display = false
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
export KAFKA_SERVER=${google_compute_address.kafka.address}
${file("./kafka-connect/setup.sh")}
EOF
}
