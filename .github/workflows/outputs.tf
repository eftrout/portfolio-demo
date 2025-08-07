output "s3_bucket_name" {
  description = "Name of the S3 bucket created"
  value       = aws_s3_bucket.site_bucket[0].bucket
  condition   = var.site_enabled
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.cdn[0].domain_name
  condition   = var.site_enabled
}
