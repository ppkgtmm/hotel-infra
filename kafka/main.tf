resource "aws_msk_serverless_cluster" "hotel-kafka" {
  cluster_name = "hotel-kafka"
  vpc_config {
    subnet_ids         = var.subnets
    security_group_ids = [var.security-group-id]
  }
  client_authentication {
    sasl {
      iam {
        enabled = true
      }
    }
  }
}

data "aws_msk_bootstrap_brokers" "kafka-servers" {
  cluster_arn = aws_msk_serverless_cluster.hotel-kafka.arn
}
