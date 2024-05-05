resource "aws_db_instance" "source-db" {
  instance_class      = "db.t3.micro"
  engine              = "postgres"
  engine_version      = "15.6"
  skip_final_snapshot = true
  multi_az            = false
  identifier          = var.source-db-name
  db_name             = var.source-db-name
  username            = var.source-db-username
  password            = var.source-db-password
  allocated_storage   = 5
  publicly_accessible = true
  availability_zone   = var.aws_zone
}

resource "aws_instance" "data-seeder" {
  instance_type        = "t2.micro"
  ami                  = "ami-0be48b687295f8bd6"
  user_data            = <<EOF
#!/bin/bash
export S3_BUCKET=${var.bucket-id}
export AWS_REGION=${var.aws_region}
export SOURCE_DB=postgresql://${aws_db_instance.source-db.username}:${aws_db_instance.source-db.password}@${aws_db_instance.source-db.endpoint}/${aws_db_instance.source-db.db_name}
${file("./data-seeder/setup.sh")}
EOF
  iam_instance_profile = var.data-seeder-role
  tags = {
    Name = "data-seeder"
  }
  availability_zone = var.aws_zone
}
