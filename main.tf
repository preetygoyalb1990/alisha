#################################
# Terraform + AWS Provider
#################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#################################
# AWS Provider Credentials
#################################

provider "aws" {
  region     = "us-east-1"
}

#################################
# S3 Bucket
#################################

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "terraform-jenkins-demo-bucket-123456"

  tags = {
    Name = "terraform-jenkins-demo-bucket-123456"
  }
}

#################################
# Public Access Block
#################################

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.demo_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

#################################
# Upload hello.txt
#################################

resource "aws_s3_object" "hello_file" {
  bucket       = aws_s3_bucket.demo_bucket.id
  key          = "hello.txt"
  source       = "hello.txt"
  content_type = "text/plain"
}

#################################
# Bucket Policy
#################################

resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.demo_bucket.id

  depends_on = [
    aws_s3_bucket_public_access_block.public_access
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.demo_bucket.arn}/*"
      }
    ]
  })
}

#################################
# Output URL
#################################

output "hello_file_url" {
  value = "https://${aws_s3_bucket.demo_bucket.bucket}.s3.amazonaws.com/hello.txt"
}