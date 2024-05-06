resource "aws_s3_object" "connector-raw" {
  bucket = var.bucket-id
  key    = var.object-key
  source = var.object-source
}
