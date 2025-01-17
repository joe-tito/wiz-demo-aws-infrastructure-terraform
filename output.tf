output "url" {
  description = "url of the bucket"
  value       = "https://${aws_s3_bucket.this.id}.s3.${aws_s3_bucket.this.region}.amazonaws.com/index.html"
}
