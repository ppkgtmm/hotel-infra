data "aws_iam_role" "data_generator_role" {
  name = var.data_generator_role
}

resource "aws_lambda_function" "data_generator" {
  function_name = "data_generator"
  role          = data.aws_iam_role.data_generator_role.arn
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
      S3_BUCKET     = var.s3_bucket_name
      AWS_REGION    = var.aws_region
      LOCATION_FILE = var.location_file
      SEED          = var.seed
      SEED_DIR      = var.seed_dir
    }
  }
}

resource "aws_lambda_invocation" "invocation" {
  function_name = aws_lambda_function.data_generator.function_name
  input         = jsonencode({})
  depends_on    = [aws_lambda_function.data_generator]
}
