output "bucket-id" {
  value = aws_s3_bucket.staging-area.id
}

output "bucket-arn" {
  value = aws_s3_bucket.staging-area.arn
}
