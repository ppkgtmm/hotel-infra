resource "aws_instance" "connector" {
  instance_type        = var.aws-instance-type
  ami                  = var.aws-ami
  user_data            = <<EOF
#!/bin/bash
export S3_BUCKET=${var.bucket-id}
export AWS_REGION=${var.aws-region}
export PLUGIN=${var.plugin}
${file("./connector/setup.sh")}
EOF
  iam_instance_profile = var.connector-role
  tags = {
    Name = "connector-setup"
  }
  availability_zone = var.aws-zone
  instance_initiated_shutdown_behavior = "stop"
}
