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
    security_group_ids = var.security_groups
    subnet_ids         = var.client_subnets
  }
  environment {
    variables = {
      DB_NAME      = var.source_db_name
      DB_HOST      = format("%s:%s", var.source_db_host, var.source_db_port)
      DB_USER      = var.source_db_username
      DB_PASSWORD  = var.source_db_password
      DBZ_USER     = var.replication_user
      DBZ_PASSWORD = var.replication_password
    }
  }
}


resource "aws_lambda_invocation" "connector_invocation" {
  function_name = aws_lambda_function.hotel_connector.function_name
  input         = jsonencode({})
  depends_on    = [aws_lambda_function.hotel_connector]
}

locals {
  debezium_server_variables = {
    KAFKA_SERVER = var.bootstrap_brokers
    DB_HOST      = var.source_db_host
    DB_PORT      = var.source_db_port
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
  user_data  = templatefile("data-streaming/debezium/initialize.sh", local.debezium_server_variables)
  depends_on = [aws_lambda_invocation.connector_invocation]
}
