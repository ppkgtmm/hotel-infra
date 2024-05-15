resource "aws_redshift_cluster" "hotel_dwh" {
  node_type           = "dc2.large"
  cluster_identifier  = "data-warehouse"
  cluster_type        = "single-node"
  database_name       = var.warehouse_db_name
  master_username     = var.warehouse_db_username
  master_password     = var.warehouse_db_password
  skip_final_snapshot = true
}

output "redshift_endpoint" {
  value = aws_redshift_cluster.hotel_dwh.endpoint
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
    subnet_ids         = data.aws_subnets.subnets.ids
  }
  environment {
    variables = {
      DWH_USER     = var.warehouse_db_username
      DWH_PASSWORD = var.warehouse_db_password
      DWH_HOST     = aws_redshift_cluster.hotel_dwh.endpoint
      DWH_NAME     = var.warehouse_db_name
    }
  }
  depends_on = [aws_redshift_cluster.hotel_dwh]
}

resource "aws_lambda_invocation" "processor_invocation" {
  function_name = aws_lambda_function.hotel_processor.function_name
  input         = jsonencode({})
  # depends_on    = [aws_lambda_function.hotel_processor]
}
