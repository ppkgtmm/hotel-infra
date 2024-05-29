locals {
  data_generator_variables = {
    GIT_REPO = "https://github.com/ppkgtmm/hotel-datagen.git"
    ENVIRONMENT = {
      LOCATION_FILE = "https://github.com/ppkgtmm/location/raw/main/states_provinces.csv"
      SEED          = 42
      SEED_DIR      = var.seed_directory
      S3_BUCKET     = var.s3_bucket_name
      AWS_REGION    = var.aws_region
    }
  }
}

resource "aws_instance" "data_generator" {
  instance_type        = var.instance_type
  ami                  = var.ubuntu_ami
  user_data            = templatefile("initialize.sh", local.data_generator_variables)
  iam_instance_profile = "s3-access"
  tags = {
    Name = "data-generator"
  }
  availability_zone = var.availability_zone
}
