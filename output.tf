output "s3_url" {
  description = "url of the bucket"
  value       = "https://${aws_s3_bucket.this.id}.s3.${aws_s3_bucket.this.region}.amazonaws.com/index.html"
}

# output "ec2_public_dns" {
#   description = "public dns for mongo ec2 instance"
#   value       = aws_instance.mongo.public_dns
# }
