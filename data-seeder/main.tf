resource "aws_db_parameter_group" "source-db" {
  name   = "${var.source-db-name}-postgres15-6"
  family = "postgres15"
  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
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
  availability_zone    = var.aws-zone
  parameter_group_name = aws_db_parameter_group.source-db.name
}

resource "aws_instance" "data-seeder" {
  instance_type        = var.aws-instance-type
  ami                  = var.aws-ami
  user_data            = <<EOF
#!/bin/bash
export S3_BUCKET=${var.bucket-id}
export AWS_REGION=${var.aws-region}
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
  availability_zone = var.aws-zone
}
