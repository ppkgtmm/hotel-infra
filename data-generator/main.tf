resource "aws_instance" "data-generator" {
  instance_type        = var.aws_instance_type
  ami                  = var.aws_ami
  user_data            = <<EOF
#!/bin/bash
export S3_BUCKET=${var.s3_bucket_name}
export AWS_REGION=${var.aws_region}
${file("./data-generator/setup.sh")}
EOF
  iam_instance_profile = var.data_generator_role
  tags = {
    Name = "data-generator"
  }
  availability_zone = var.aws_zone
}
