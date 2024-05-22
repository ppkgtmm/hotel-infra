resource "aws_subnet" "private_subnet" {
  vpc_id                  = data.aws_vpc.default.id
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false
  cidr_block              = "172.31.48.0/20"
  depends_on              = [aws_instance.debezium]
}

resource "aws_route_table" "private_table" {
  vpc_id = data.aws_vpc.default.id

  route {
    cidr_block = data.aws_vpc.default.cidr_block
    gateway_id = "local"
  }
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_table.id
}

data "aws_route_table" "main_table" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "association.main"
    values = ["true"]
  }
}

resource "aws_vpc_endpoint" "emr_endpoint" {
  vpc_id             = data.aws_vpc.default.id
  service_name       = "com.amazonaws.${var.aws_region}.emr-serverless"
  subnet_ids         = [aws_subnet.private_subnet.id]
  security_group_ids = [data.aws_security_group.default.id]
  vpc_endpoint_type  = "Interface"
}

resource "aws_route" "emr_route" {
  route_table_id         = data.aws_route_table.main_table.id
  destination_cidr_block = aws_subnet.private_subnet.cidr_block
  network_interface_id   = aws_vpc_endpoint.emr_endpoint.network_interface_ids
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
