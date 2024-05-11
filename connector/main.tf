data "aws_iam_role" "connector_role" {
  name = var.connector_role
}

resource "aws_lambda_function" "hotel_connector" {
  function_name = "hotel_connector"
  role          = data.aws_iam_role.connector_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  s3_bucket     = var.s3_bucket_name
  s3_key        = var.function_zip_file
  skip_destroy  = false
  timeout       = 10
  vpc_config {
    security_group_ids = [var.aws_security_group]
    subnet_ids         = var.aws_subnet_ids
  }
  environment {
    variables = {
      DB_NAME                = var.source_db_name
      DB_HOST                = "${var.source_db_address}:${var.source_db_port}"
      DB_USER                = var.source_db_username
      DB_PASSWORD            = var.source_db_password
      DBZ_USER               = var.replication_user
      DBZ_PASSWORD           = var.replication_password
      KAFKA_CONNECT_SERVER   = "http://${var.kafka_connect_server}:8083"
    }
  }
}

resource "aws_lambda_invocation" "invocation" {
  function_name = aws_lambda_function.hotel_connector.function_name
  input         = jsonencode({})
  depends_on    = [aws_lambda_function.hotel_connector]
}
