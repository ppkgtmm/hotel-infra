data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "availability-zone"
    values = [var.aws-zone]
  }
}
data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_msk_cluster" "hotel-kafka" {
  cluster_name           = "hotel-kafka"
  kafka_version          = "3.2.0"
  number_of_broker_nodes = 1

  broker_node_group_info {
    instance_type  = "kafka.m7g.large"
    client_subnets = data.aws_subnets.subnets.ids
    storage_info {
      ebs_storage_info {
        volume_size = 5
      }
    }
    security_groups = [data.aws_security_group.default.id]
  }
}
