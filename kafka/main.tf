resource "random_uuid" "rand" {}

resource "google_compute_instance" "kafka" {
  for_each       = var.kafka_bootstrap_servers
  machine_type   = var.gcp_machine_type
  name           = each.value
  enable_display = false
  boot_disk {
    initialize_params {
      image = var.gcp_disk_image
      size  = 10
      type  = var.gcp_disk_type
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
export KAFKA_NODE_ID=${each.key}
export KAFKA_VOTERS=${join(",", [for id, server in var.kafka_bootstrap_servers : format("%s@%s:9093", id, server)])}
${file("./kafka/setup.sh")}
EOF
}
