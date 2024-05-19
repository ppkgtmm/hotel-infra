
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
    subnet_ids         = slice(data.aws_subnets.subnets.ids, 0, 1)[0]
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

resource "aws_lambda_invocation" "connector_invocation" {
  function_name = aws_lambda_function.hotel_connector.function_name
  input         = jsonencode({})
  # depends_on    = [aws_lambda_function.hotel_connector]
}

resource "aws_lambda_function" "hotel_processor" {
  function_name = "hotel-processor"
  role          = data.aws_iam_role.lambda_role.arn
  handler       = "entrypoint.handler"
  runtime       = "python3.12"
  s3_bucket     = var.s3_bucket_name
  s3_key        = "hotel-processor.zip"
  skip_destroy  = false
  timeout       = 10
  vpc_config {
    security_group_ids = [data.aws_security_group.default.id]
    subnet_ids         = slice(data.aws_subnets.subnets.ids, 0, 1)[0]
  }
  environment {
    variables = {
      DWH_USER     = var.warehouse_db_username
      DWH_PASSWORD = var.warehouse_db_password
      DWH_HOST     = aws_redshift_cluster.hotel_dwh.endpoint
      DWH_NAME     = var.warehouse_db_name
    }
  }
  # depends_on = [aws_redshift_cluster.hotel_dwh]
}

resource "aws_lambda_invocation" "processor_invocation" {
  function_name = aws_lambda_function.hotel_processor.function_name
  input         = jsonencode({})
  # depends_on    = [aws_lambda_function.hotel_processor]
}