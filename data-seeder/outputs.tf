output "source-db-host" {
  value = aws_db_instance.source-db.address
}

output "source-db-port" {
  value = aws_db_instance.source-db.port
}
