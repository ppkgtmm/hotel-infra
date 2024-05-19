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