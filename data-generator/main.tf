resource "aws_s3_bucket" "staging-area" {
  bucket        = "${var.account-id}-staging-area"
  force_destroy = true
}

resource "aws_instance" "data-generator" {
  instance_type        = var.aws-instance-type
  ami                  = var.aws-ami
  user_data            = <<EOF
#!/bin/bash
export S3_BUCKET=${aws_s3_bucket.staging-area.id}
export aws-region=${var.aws-region}
${file("./data-generator/setup.sh")}
EOF
  iam_instance_profile = var.data-generator-role
  tags = {
    Name = "data-generator"
  }
  availability_zone = var.aws-zone
}
