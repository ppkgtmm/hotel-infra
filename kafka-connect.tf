resource "random_uuid" "rand" {}
# resource "google_compute_address" "kafka" {
#   name         = "kafka-ip-address"
#   address_type = "INTERNAL"
#   subnetwork   = var.gcp_network
#   region       = var.gcp_region
#   # ip_version   = "IPV6"
# }

# resource "google_compute_address" "kafka-connect" {
#   name = "kafka-connect-ipv4-address"
# }

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
export KAFKA_CLUSTER_ID=${random_uuid.rand.id}
${file("./kafka/setup.sh")}
EOF
  # export KAFKA_SERVER=${google_compute_address.kafka.address}
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
export KAFKA_SERVER=${google_compute_instance.kafka.network_interface[0].network_ip}
${file("./kafka-connect/setup.sh")}
EOF
}

# resource "google_compute_firewall" "kafka-firewall" {
#   name     = "kafka-firewall"
#   network  = var.gcp_network
#   priority = 65535
#   allow {
#     protocol = "tcp"
#     ports    = ["9092"]
#   }
#   source_ranges = [":::"]
#   source_tags   = google_compute_instance.kafka-connect.tags
#   target_tags   = google_compute_instance.kafka.tags
# }
