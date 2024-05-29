# data "aws_iam_role" "submit_role" {
#   name = "emr-serverless-access"
# }

# data "aws_iam_role" "execution_role" {
#   name = "redshift-s3-access"
# }

# resource "aws_lambda_function" "hotel_submit" {
#   function_name = "hotel-submit"
#   role          = data.aws_iam_role.submit_role.arn
#   handler       = "entrypoint.handler"
#   runtime       = "python3.12"
#   s3_bucket     = var.s3_bucket_name
#   s3_key        = "hotel-submit.zip"
#   skip_destroy  = false
#   timeout       = 10
#   vpc_config {
#     security_group_ids = [data.aws_security_group.default.id]
#     subnet_ids         = [data.aws_subnet.default_subnet.id]
#   }
#   environment {
#     variables = {
#       KAFKA_SERVER   = join(",", formatlist("%s:9092", aws_instance.kafka[*].private_ip))
#       DWH_USER       = var.warehouse_db_username
#       DWH_PASSWORD   = var.warehouse_db_password
#       DWH_HOST       = aws_redshift_cluster.hotel_dwh.endpoint
#       DWH_NAME       = var.warehouse_db_name
#       DB_NAME        = var.source_db_name
#       S3_BUCKET      = var.s3_bucket_name
#       REGION         = var.aws_region
#       APPLICATION_ID = aws_emrserverless_application.hotel_stream.id
#       EXECUTION_ROLE = data.aws_iam_role.execution_role.arn
#     }
#   }
#   depends_on = [aws_route.emr_route]
# }

# resource "aws_lambda_invocation" "submit_invocation" {
#   function_name = aws_lambda_function.hotel_submit.function_name
#   input         = jsonencode({})
# }