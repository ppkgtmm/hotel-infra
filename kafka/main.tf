resource "aws_msk_cluster" "hotel_kafka" {
  cluster_name           = "hotel-kafka"
  kafka_version          = "3.2.0"
  number_of_broker_nodes = 2

  broker_node_group_info {
    instance_type  = "kafka.t3.small"
    client_subnets = var.aws_subnets
    storage_info {
      ebs_storage_info {
        volume_size = 10
      }
    }
    security_groups = [var.aws_security_group]
  }
}
