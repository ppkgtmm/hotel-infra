resource "aws_instance" "kafka_connect" {
  instance_type = "t2.medium"
  ami           = var.aws_ami
  user_data     = <<EOF
#!/bin/bash
export KAFKA_SERVERS=${var.kafka_bootstrap_servers}
${file("./kafka-connect/setup.sh")}
EOF
  tags = {
    Name = "kafka-connect"
  }
  availability_zone    = var.aws_zone
  iam_instance_profile = var.kafka_connect_role
}
