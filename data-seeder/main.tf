resource "aws_db_parameter_group" "source-db" {
  name   = "${var.source-db-name}-postgres15.6"
  family = "postgres15.6"

  parameter {
    name  = "logical_replication"
    value = "1"
  }
  parameter {
    name  = "log_replication_commands"
    value = "1"
  }
  parameter {
    name  = "log_statement"
    value = "all"
  }
}

resource "aws_db_instance" "source-db" {
  instance_class       = "db.t3.micro"
  engine               = "postgres"
  engine_version       = "15.6"
  skip_final_snapshot  = true
  multi_az             = false
  identifier           = var.source-db-name
  db_name              = var.source-db-name
  username             = var.source-db-username
  password             = var.source-db-password
  allocated_storage    = 5
  publicly_accessible  = true
  availability_zone    = var.aws_zone
  parameter_group_name = aws_db_parameter_group.source-db.name
}

resource "aws_instance" "data-seeder" {
  instance_type        = "t2.micro"
  ami                  = "ami-0be48b687295f8bd6"
  user_data            = <<EOF
#!/bin/bash
export S3_BUCKET=${var.bucket-id}
export AWS_REGION=${var.aws_region}
export DB_USER=${aws_db_instance.source-db.username}
export DB_PASSWORD=${aws_db_instance.source-db.password}
export DB_ENDPOINT=${aws_db_instance.source-db.endpoint}
export DB_NAME=${aws_db_instance.source-db.db_name}
${file("./data-seeder/setup.sh")}
EOF
  iam_instance_profile = var.data-seeder-role
  tags = {
    Name = "data-seeder"
  }
  availability_zone = var.aws_zone
}
