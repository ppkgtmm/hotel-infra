data "aws_iam_role" "connector_role" {
  name = "s3-ec2-access"
}

resource "aws_lambda_function" "hotel_connector" {
  function_name = "hotel_connector"
  role          = data.aws_iam_role.connector_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  s3_bucket     = var.s3_bucket_name
  s3_key        = "hotel-connector.zip"
  skip_destroy  = false
  timeout       = 10
  vpc_config {
    security_group_ids = [data.aws_security_group.default.id]
    subnet_ids         = data.aws_subnets.subnets.ids
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

resource "aws_lambda_invocation" "invocation" {
  function_name = aws_lambda_function.hotel_connector.function_name
  input         = jsonencode({})
  depends_on    = [aws_lambda_function.hotel_connector]
}

resource "aws_network_interface" "kafka_network_interface" {
  subnet_id         = slice(data.aws_subnets.subnets.ids, 0, 1)[0]
  private_ips_count = 3
  security_groups   = [data.aws_security_group.default.id]
}

resource "random_uuid" "cluster_id" {}

resource "aws_instance" "kafka" {
  availability_zone = var.availability_zone
  ami               = var.ubuntu_ami
  instance_type     = var.instance_type
  count             = aws_network_interface.kafka_network_interface.private_ips_count
  tags = {
    Name = "kafka-server-${count.index + 1}"
  }
  private_ip = aws_network_interface.kafka_network_interface.private_ip_list[count.index]
  user_data = templatefile("./kafka/initialize.sh", {
    NODE_ID          = count.index + 1,
    VOTERS           = join(",", [for idx, ip in aws_network_interface.kafka_network_interface.private_ip_list : format("%s@%s:9092", idx + 1, ip)])
    KAFKA_CLUSTER_ID = random_uuid.cluster_id.id
  })
}

locals {
  debezium_server_variables = {
    KAFKA_SERVER = join(",", [for ip in aws_network_interface.kafka_network_interface.private_ip_list : format("%s:9092", ip)])
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
  user_data = templatefile("./debezium/initialize.sh", local.debezium_server_variables)
}
