resource "aws_instance" "connector" {
  instance_type        = var.aws-instance-type
  ami                  = var.aws-ami
  user_data            = <<EOF
#!/bin/bash
export DB_HOST=${var.source-db-host}
export DB_PORT=${var.source-db-port}
export DB_USER=${var.source-db-user}
export DB_PASSWORD=${var.source-db-password}
export DB_NAME=${var.source-db-name}
export DBZ_USER=${var.replication-user}
export DBZ_PASSWORD=${var.replication-password}
${file("./connector/setup.sh")}
EOF
  iam_instance_profile = var.connector-role
  tags = {
    Name = "connector-setup"
  }
  availability_zone = var.aws-zone
}
