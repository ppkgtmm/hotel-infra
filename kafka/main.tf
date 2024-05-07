resource "aws_msk_serverless_cluster" "hotel-kafka" {
  cluster_name = "hotel-kafka"
  vpc_config {
    subnet_ids         = slice(var.subnets, 0, 2)
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
