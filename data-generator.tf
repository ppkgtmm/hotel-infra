resource "aws_s3_bucket" "staging-area" {
  bucket        = "${data.aws_caller_identity.current.account_id}-staging-area"
  force_destroy = true
}

resource "aws_instance" "data-generator" {
  instance_type        = "t2.micro"
  ami                  = "ami-0be48b687295f8bd6"
  user_data            = <<EOF
#!/bin/bash
export S3_BUCKET=${aws_s3_bucket.staging-area.id}
export AWS_REGION=${var.aws_region}
${file("./datagen/setup.sh")}
EOF
  iam_instance_profile = var.data-generator-role
  tags = {
    Name = "data-generator"
  }
  availability_zone = var.aws_zone
}