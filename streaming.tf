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

locals {
  debezium_server_variables = {
    KAFKA_SERVER = ""
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
  # iam_instance_profile = var.debezium_role
  tags = {
    Name = "debezium-server"
  }
  user_data = templatefile("./debezium/initialize.sh", local.debezium_server_variables)
}
