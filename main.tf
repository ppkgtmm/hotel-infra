terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.47.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
}

provider "aws" { region = var.aws_region }

provider "random" {}

data "aws_vpc" "default" { default = true }

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
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
  # depends_on = [aws_redshift_cluster.hotel_dwh]
}

resource "aws_lambda_invocation" "processor_invocation" {
  function_name = aws_lambda_function.hotel_processor.function_name
  input         = jsonencode({})
  # depends_on    = [aws_lambda_function.hotel_processor]
}
