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
  publicly_accessible  = true
  availability_zone    = var.aws_zone
  parameter_group_name = aws_db_parameter_group.source_db.name
}

resource "aws_instance" "data-seeder" {
  instance_type        = var.aws_instance_type
  ami                  = var.aws_ami
  user_data            = <<EOF
#!/bin/bash
export S3_BUCKET=${var.s3_bucket_name}
export AWS_REGION=${var.aws_region}
export DB_USER=${aws_db_instance.source_db.name}
export DB_PASSWORD=${aws_db_instance.source_db.password}
export DB_ENDPOINT=${aws_db_instance.source_db.endpoint}
export DB_NAME=${aws_db_instance.source_db}
${file("./data-seeder/setup.sh")}
EOF
  iam_instance_profile = var.data_seeder_role
  tags = {
    Name = "data-seeder"
  }
  availability_zone = var.aws_zone
}
