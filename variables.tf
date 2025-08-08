# AWS Region
variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-2"
}

# Enable or disable deployment
variable "site_enabled" {
  description = "Enable or disable the entire site deployment"
  type        = bool
  default     = true
}

# Base bucket name (suffix will be added)
variable "bucket_name" {
  description = "Base name for S3 bucket"
  type        = string
  default     = "hello-worldterraforming"
}

# Common tags for resources
variable "project_tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    Project      = "PortfolioDemo"
    Owner        = "alejandro-lopez"
    AutoShutdown = "true"
  }
}
