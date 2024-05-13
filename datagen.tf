locals {
  data_generator_variables = {
    GIT_REPO = "https://github.com/ppkgtmm/hotel-datagen.git"
    ENVIRONMENT = {
      LOCATION_FILE = "https://github.com/ppkgtmm/location/raw/main/states_provinces.csv"
      SEED          = 42
      SEED_DIR      = var.seed_directory
    }
  }
}

resource "aws_instance" "data_generator" {
  instance_type        = var.instance_type
  ami                  = var.ubuntu_ami
  user_data            = templatefile("./initialize.sh", local.data_generator_variables)
  iam_instance_profile = "s3-access"
  tags = {
    Name = "data-seeder"
  }
  availability_zone = var.availability_zone
}
