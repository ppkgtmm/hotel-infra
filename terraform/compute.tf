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
  filter {
    name   = "defaultForAz"
    values = ["true"]
  }
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

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
  user_data            = templatefile("../initialize.sh", local.data_generator_variables)
  iam_instance_profile = "s3-access"
  tags = {
    Name = "data-generator"
  }
  availability_zone = var.availability_zone
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
  user_data            = templatefile("../initialize.sh", local.data_seeder_variables)
  iam_instance_profile = "rds-s3-access"
  tags = {
    Name = "data-seeder"
  }
  availability_zone = var.availability_zone
  depends_on        = [aws_db_instance.source_db, aws_instance.data_generator]
}

resource "aws_network_interface" "kafka_network_interface" {
  subnet_id       = slice(data.aws_subnets.subnets.ids, 0, 1)[0]
  count           = 3
  security_groups = [data.aws_security_group.default.id]
  depends_on      = [aws_instance.data_seeder]
}

resource "random_uuid" "cluster_id" {}

resource "aws_instance" "kafka" {
  availability_zone = var.availability_zone
  ami               = var.ubuntu_ami
  instance_type     = var.instance_type
  count             = 3
  tags = {
    Name = "kafka-server-${count.index + 1}"
  }
  network_interface {
    network_interface_id = aws_network_interface.kafka_network_interface[count.index].id
    device_index         = 0
  }
  user_data = templatefile("../kafka/initialize.sh", {
    NODE_ID          = count.index + 1
    VOTERS           = join(",", formatlist("%s@%s:9093", range(1, 4), aws_network_interface.kafka_network_interface[*].private_ip))
    KAFKA_CLUSTER_ID = random_uuid.cluster_id.id
  })
  # depends_on = [aws_network_interface.kafka_network_interface]
}

locals {
  debezium_server_variables = {
    KAFKA_SERVER = join(",", formatlist("%s:9091", aws_network_interface.kafka_network_interface[*].private_ip))
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
  user_data  = templatefile("../debezium/initialize.sh", local.debezium_server_variables)
  depends_on = [aws_lambda_invocation.connector_invocation, aws_instance.kafka]
}
