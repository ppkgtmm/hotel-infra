
resource "aws_network_interface" "kafka_network_interface" {
  subnet_id       = slice(data.aws_subnets.subnets.ids, 0, 1)[0]
  count           = 3
  security_groups = [data.aws_security_group.default.id]
  depends_on      = [aws_instance.data_seeder]
}

resource "random_uuid" "cluster_id" {}

resource "aws_instance" "kafka" {
  availability_zone = var.availability_zone
  ami               = var.ubuntu_ami
  instance_type     = var.instance_type
  count             = 3
  tags = {
    Name = "kafka-server-${count.index + 1}"
  }
  network_interface {
    network_interface_id = aws_network_interface.kafka_network_interface[count.index].id
    device_index         = 0
  }
  user_data = templatefile("../kafka/initialize.sh", {
    NODE_ID          = count.index + 1
    VOTERS           = join(",", formatlist("%s@%s:9093", range(1, 4), aws_network_interface.kafka_network_interface[*].private_ip))
    KAFKA_CLUSTER_ID = random_uuid.cluster_id.id
  })
  # depends_on = [aws_network_interface.kafka_network_interface]
}

locals {
  debezium_server_variables = {
    KAFKA_SERVER = join(",", formatlist("%s:9091", aws_network_interface.kafka_network_interface[*].private_ip))
    DB_HOST      = aws_db_instance.source_db.address
    DB_PORT      = aws_db_instance.source_db.port
    DB_USER      = var.replication_user
    DB_PASSWORD  = var.replication_password
    DB_NAME      = var.source_db_name
  }
}

resource "aws_instance" "debezium" {
  availability_zone = var.availability_zone
  ami               = var.ubuntu_ami
  instance_type     = var.instance_type
  tags = {
    Name = "debezium-server"
  }
  user_data  = templatefile("../debezium/initialize.sh", local.debezium_server_variables)
  depends_on = [aws_lambda_invocation.connector_invocation, aws_instance.kafka]
}

output "kafka_ips" {
  value = join(",", formatlist("%s:9092", aws_instance.kafka[*].public_ip))
}
