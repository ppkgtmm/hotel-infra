resource "aws_msk_cluster" "hotel-kafka" {
  cluster_name           = "hotel-kafka"
  kafka_version          = "3.5.1"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type  = "kafka.t3.small"
    client_subnets = var.subnets
    storage_info {
      ebs_storage_info {
        volume_size = 5
      }
    }
    security_groups = [var.security-group-id]
  }
}

