resource "aws_subnet" "private_subnet" {
  vpc_id                  = data.aws_vpc.default.id
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false
  cidr_block              = "172.31.48.0/20"
  depends_on              = [aws_instance.debezium]
}

resource "aws_route_table" "private_route" {
  vpc_id = data.aws_vpc.default.id

  route {
    cidr_block = data.aws_vpc.default.cidr_block
    gateway_id = "local"
  }
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_emrserverless_application" "hotel_stream" {
  name          = "hotel-stream"
  release_label = "emr-7.0.0"
  type          = "spark"
  auto_stop_configuration {
    idle_timeout_minutes = 1
  }
  initial_capacity {
    initial_capacity_type = "Driver"
    initial_capacity_config {
      worker_count = 1
      worker_configuration {
        cpu    = "1 vCPU"
        memory = "2 GB"
        disk   = "20 GB"
      }
    }
  }
  initial_capacity {
    initial_capacity_type = "Executor"
    initial_capacity_config {
      worker_count = 2
      worker_configuration {
        cpu    = "1 vCPU"
        memory = "2 GB"
        disk   = "20 GB"
      }
    }
  }
  maximum_capacity {
    cpu    = "3 vCPU"
    memory = "6 GB"
    disk   = "60 GB"
  }
  network_configuration {
    security_group_ids = [data.aws_security_group.default.id]
    subnet_ids         = [aws_subnet.private_subnet.id]
  }
  depends_on = [aws_instance.debezium, aws_route_table_association.private_association]
}
