resource "aws_msk_configuration" "config" {
  name              = "hotel-kafka-config"
  server_properties = file("./kafka/kafka.properties")
}

resource "aws_msk_cluster" "kafka" {
  cluster_name           = "hotel-kafka"
  kafka_version          = "3.5.1"
  number_of_broker_nodes = 2

  broker_node_group_info {
    instance_type  = "kafka.t3.small"
    client_subnets = slice(tolist(var.aws_subnet_ids), 0, 2)
    storage_info {
      ebs_storage_info {
        volume_size = 10
      }
    }
    security_groups = [var.aws_security_group]
  }
  configuration_info {
    arn      = aws_msk_configuration.config.arn
    revision = aws_msk_configuration.config.latest_revision
  }
}
