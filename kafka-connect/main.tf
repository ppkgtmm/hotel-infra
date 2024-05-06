resource "aws_mskconnect_worker_configuration" "hotel-connect" {
  name                    = "hotel-connect"
  properties_file_content = file("./kafka-connect/connect.properties")
}

data "aws_s3_bucket" "bucket" {
  bucket = var.bucket-id
}

data "aws_iam_role" "connect-role" {
  name = var.connect-role
}

resource "aws_mskconnect_custom_plugin" "plugin" {
  name         = "debezium-postgres"
  content_type = "ZIP"
  location {
    s3 {
      bucket_arn = data.aws_s3_bucket.bucket.arn
      file_key   = var.plugin-path
    }
  }
}

resource "aws_mskconnect_connector" "hotel-connect" {
  name                 = "hotel-connect"
  kafkaconnect_version = "2.7.1"
  capacity {
    autoscaling {
      max_worker_count = 1
      min_worker_count = 1
    }
  }
  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = var.kafka-servers
      vpc {
        security_groups = [var.security-group-id]
        subnets         = var.subnets
      }
    }
  }
  connector_configuration = {
    # "connector.class" = "com.github.jcustenborder.kafka.connect.simulator.SimulatorSinkConnector"
    # "tasks.max"       = "1"
    # "topics"          = "example"
  }
  kafka_cluster_client_authentication {}
  kafka_cluster_encryption_in_transit {}

  plugin {
    custom_plugin {
      arn      = aws_mskconnect_custom_plugin.plugin.arn
      revision = aws_mskconnect_custom_plugin.plugin.latest_revision
    }
  }
  service_execution_role_arn = data.aws_iam_role.connect-role.arn
  worker_configuration {
    arn      = aws_mskconnect_worker_configuration.hotel-connect.arn
    revision = aws_mskconnect_worker_configuration.hotel-connect.latest_revision
  }
}
