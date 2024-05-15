locals {
  data_generator_variables = {
    GIT_REPO = "https://github.com/ppkgtmm/hotel-datagen.git"
    ENVIRONMENT = {
      LOCATION_FILE = "https://github.com/ppkgtmm/location/raw/main/states_provinces.csv"
      SEED          = 42
      SEED_DIR      = var.seed_directory
      S3_BUCKET     = var.s3_bucket_name
      AWS_REGION    = var.aws_region
    }
  }
}

resource "aws_instance" "data_generator" {
  instance_type        = var.instance_type
  ami                  = var.ubuntu_ami
  user_data            = templatefile("./initialize.sh", local.data_generator_variables)
  iam_instance_profile = "s3-access"
  tags = {
    Name = "data-generator"
  }
  availability_zone = var.availability_zone
}

resource "aws_db_parameter_group" "source_db" {
  name   = "${var.source_db_name}-postgres15-6"
  family = "postgres15"
  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
  }
}

resource "aws_db_instance" "source_db" {
  instance_class       = "db.t3.micro"
  engine               = "postgres"
  engine_version       = "15.6"
  skip_final_snapshot  = true
  multi_az             = false
  identifier           = var.source_db_name
  db_name              = var.source_db_name
  username             = var.source_db_username
  password             = var.source_db_password
  allocated_storage    = 5
  availability_zone    = var.availability_zone
  parameter_group_name = aws_db_parameter_group.source_db.name
}

locals {
  data_seeder_variables = {
    GIT_REPO = "https://github.com/ppkgtmm/hotel-seed.git"
    ENVIRONMENT = {
      LOCATION_FILE = "https://github.com/ppkgtmm/location/raw/main/states_provinces.csv"
      SEED          = 42
      SEED_DIR      = var.seed_directory
      S3_BUCKET     = var.s3_bucket_name
      AWS_REGION    = var.aws_region
      DB_USER       = aws_db_instance.source_db.username
      DB_PASSWORD   = aws_db_instance.source_db.password
      DB_ENDPOINT   = aws_db_instance.source_db.endpoint
      DB_NAME       = aws_db_instance.source_db.db_name
    }
  }
}
resource "aws_instance" "data_seeder" {
  instance_type        = var.instance_type
  ami                  = var.ubuntu_ami
  user_data            = templatefile("./initialize.sh", local.data_seeder_variables)
  iam_instance_profile = "rds-s3-access"
  tags = {
    Name = "data-seeder"
  }
  availability_zone = var.availability_zone
  depends_on        = [aws_db_instance.source_db, aws_instance.data_generator]
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
  # depends_on    = [aws_lambda_function.hotel_connector]
}
