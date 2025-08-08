# Main Terraform: Private S3 + CloudFront (OAC) secure static site
# Uses variables from variables.tf

provider "aws" {
  region = var.aws_region
}

# Create S3 bucket (kept private) for website content
# this bucket will be used as the origin for CloudFront
resource "aws_s3_bucket" "site_bucket" {
  count  = var.site_enabled ? 1 : 0
  bucket = var.bucket_name

  tags = var.project_tags
}

# Keep public access blocked (recommended)
resource "aws_s3_bucket_public_access_block" "block_public" {
  count  = var.site_enabled ? 1 : 0
  bucket = aws_s3_bucket.site_bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable website configuration (optional — CloudFront will use the bucket as origin)
resource "aws_s3_bucket_website_configuration" "site_config" {
  count  = var.site_enabled ? 1 : 0
  bucket = aws_s3_bucket.site_bucket[0].id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Upload index.html to the bucket (object will NOT be public)
resource "aws_s3_object" "site_index" {
  count        = var.site_enabled ? 1 : 0
  bucket       = aws_s3_bucket.site_bucket[0].id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  # Do NOT set acl = "public-read" — we keep bucket private and let CloudFront fetch
}

# CloudFront Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "oac" {
  count                             = var.site_enabled ? 1 : 0
  name                              = "${var.bucket_name}-oac"
  description                       = "OAC for CloudFront to access S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront distribution, using the OAC to securely fetch from S3
resource "aws_cloudfront_distribution" "cdn" {
  count = var.site_enabled ? 1 : 0

  enabled             = true
  default_root_object = "index.html" 

  origin {
    domain_name              = aws_s3_bucket.site_bucket[0].bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.site_bucket[0].id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac[0].id
  }

  default_cache_behavior {
    target_origin_id       = "S3-${aws_s3_bucket.site_bucket[0].id}"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.project_tags
}

# S3 bucket policy to allow CloudFront (only) to GetObject from the bucket
resource "aws_s3_bucket_policy" "site_policy" {
  count  = var.site_enabled ? 1 : 0
  bucket = aws_s3_bucket.site_bucket[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.site_bucket[0].arn}/*"
        Condition = {
          StringEquals = {
            # Restrict by SourceArn to the CloudFront distribution
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn[0].arn
          }
        }
      }
    ]
  })
}

# Outputs
output "s3_bucket_name" {
  value       = aws_s3_bucket.site_bucket[0].bucket
  description = "S3 bucket name (private)"
  depends_on  = [aws_s3_object.site_index]
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.cdn[0].domain_name
  description = "CloudFront domain (use this URL to access your site)"
}

output "cloudfront_index_url" {
  value       = "https://${aws_cloudfront_distribution.cdn[0].domain_name}/index.html"
  description = "Direct link to index.html via CloudFront"
}