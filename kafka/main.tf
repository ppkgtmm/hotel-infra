resource "aws_msk_serverless_cluster" "kafka" {
  cluster_name = "hotel-kafka"
  vpc_config {
    subnet_ids         = slice(tolist(var.aws_subnet_ids), 0, 2)
    security_group_ids = [var.aws_security_group]
  }
  client_authentication {
    sasl {
      iam {
        enabled = true
      }
    }
  }
}

data "aws_msk_bootstrap_brokers" "kafka_brokers" {
  cluster_arn = aws_msk_serverless_cluster.kafka.arn
}
