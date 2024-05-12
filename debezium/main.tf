resource "aws_instance" "debezium" {
  availability_zone = var.aws_zone
  ami               = var.aws_ami
  instance_type     = var.aws_instance_type
  tags = {
    Name = "debezium-server"
  }
  user_data = <<EOF
#!/bin/bash
export DB_HOST=${var.source_db_host}
export DB_PORT=${var.source_db_port}
export DB_USER=${var.replication_user}
export DB_PASSWORD=${var.replication_password}
export DB_NAME=${var.source_db_name}
${file("./debezium/setup.sh")}
EOF
}
