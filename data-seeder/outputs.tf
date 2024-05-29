output "source_db_host" {
  value = aws_db_instance.source_db.address
}

output "source_db_port" {
  value = aws_db_instance.source_db.port
}
