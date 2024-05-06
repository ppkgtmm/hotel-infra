variable "bucket-id" {
  type = string
}

variable "object-key" {
  default = "plugin/debezium-connector-postgres-2.6.1.Final-plugin.tar.gz"
}

variable "object-source" {
  default = "https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/2.6.1.Final/debezium-connector-postgres-2.6.1.Final-plugin.tar.gz"
}
