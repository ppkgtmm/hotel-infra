resource "random_uuid" "rand" {}

resource "google_compute_instance" "kafka" {
  for_each       = var.kafka-bootstrap-servers
  machine_type   = var.gcp-machine-type
  name           = each.value
  enable_display = false
  boot_disk {
    initialize_params {
      image = var.gcp-disk-image
      size  = 10
      type  = var.gcp-disk-type
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
export KAFKA_CLUSTER_ID=${random_uuid.rand.id}
export KAFKA_NODE_ID=${each.key}
export KAFKA_VOTERS=${join(",", [for id, server in var.kafka-bootstrap-servers : format("%s@%s:9093", id, server)])}
${file("./kafka/setup.sh")}
EOF
}
