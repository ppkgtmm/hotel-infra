resource "aws_network_interface" "kafka_network_interface" {
  subnet_id       = data.aws_subnet.default_subnet.id
  count           = 3
  security_groups = [data.aws_security_group.default.id]
  depends_on      = [aws_instance.data_seeder]
}

resource "random_uuid" "cluster_id" {}

resource "aws_instance" "kafka" {
  availability_zone = var.availability_zone
  ami               = var.ubuntu_ami
  instance_type     = var.instance_type
  count             = 3
  tags = {
    Name = "kafka-server-${count.index + 1}"
  }
  network_interface {
    network_interface_id = aws_network_interface.kafka_network_interface[count.index].id
    device_index         = 0
  }
  user_data = templatefile("../kafka/initialize.sh", {
    NODE_ID          = count.index + 1
    VOTERS           = join(",", formatlist("%s@%s:9093", range(1, 4), aws_network_interface.kafka_network_interface[*].private_ip))
    KAFKA_CLUSTER_ID = random_uuid.cluster_id.id
  })
  depends_on = [aws_network_interface.kafka_network_interface]
}

locals {
  debezium_server_variables = {
    KAFKA_SERVER = join(",", formatlist("%s:9091", aws_network_interface.kafka_network_interface[*].private_ip))
    DB_HOST      = aws_db_instance.source_db.address
    DB_PORT      = aws_db_instance.source_db.port
    DB_USER      = var.replication_user
    DB_PASSWORD  = var.replication_password
    DB_NAME      = var.source_db_name
  }
}

resource "aws_instance" "debezium" {
  availability_zone = var.availability_zone
  ami               = var.ubuntu_ami
  instance_type     = var.instance_type
  tags = {
    Name = "debezium-server"
  }
  user_data  = templatefile("../debezium/initialize.sh", local.debezium_server_variables)
  depends_on = [aws_lambda_invocation.connector_invocation, aws_instance.kafka]
}

data "aws_iam_role" "lambda_role" {
  name = "s3-ec2-access"
}

resource "aws_lambda_function" "hotel_connector" {
  function_name = "hotel-connector"
  role          = data.aws_iam_role.lambda_role.arn
  handler       = "entrypoint.handler"
  runtime       = "python3.12"
  s3_bucket     = var.s3_bucket_name
  s3_key        = "hotel-connector.zip"
  skip_destroy  = false
  timeout       = 10
  vpc_config {
    security_group_ids = [data.aws_security_group.default.id]
    subnet_ids         = [data.aws_subnet.default_subnet.id]
  }
  environment {
    variables = {
      DB_NAME      = var.source_db_name
      DB_HOST      = aws_db_instance.source_db.address
      DB_USER      = var.source_db_username
      DB_PASSWORD  = var.source_db_password
      DBZ_USER     = var.replication_user
      DBZ_PASSWORD = var.replication_password
    }
  }
  depends_on = [aws_instance.data_seeder]
}
