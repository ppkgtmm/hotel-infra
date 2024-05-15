resource "aws_redshift_cluster" "hotel_dwh" {
  node_type          = "dc2.large"
  cluster_identifier = "data-warehouse"
  cluster_type       = "single-node"
  database_name      = var.warehouse_db_name
  master_username    = var.warehouse_db_username
  master_password    = var.warehouse_db_password
}

output "redshift_endpoint" {
  value = aws_redshift_cluster.hotel_dwh.endpoint
}