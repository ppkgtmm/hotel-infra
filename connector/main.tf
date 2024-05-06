resource "aws_instance" "connector" {
  instance_type        = var.aws-instance-type
  ami                  = var.aws-ami
  iam_instance_profile = var.connector-role
  tags = {
    Name = "connector-setup"
  }
  availability_zone = var.aws-zone
}
