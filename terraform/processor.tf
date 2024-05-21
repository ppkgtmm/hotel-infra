resource "aws_subnet" "hotel_private_subnet" {
  vpc_id                  = data.aws_vpc.default.id
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false
}

resource "aws_emrserverless_application" "hotel_stream" {
  name          = "hotel-stream"
  release_label = "emr-7.0.0"
  type          = "spark"
  auto_stop_configuration {
    idle_timeout_minutes = 1
  }
  maximum_capacity {
    cpu    = 3
    memory = 6
    disk   = 20
  }
  network_configuration {
    security_group_ids = [data.aws_security_group.default.id]
    subnet_ids         = [aws_subnet.hotel_private_subnet.id]
  }
  depends_on = [aws_instance.debezium]
}
