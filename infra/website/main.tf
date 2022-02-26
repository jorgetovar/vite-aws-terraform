terraform {
  backend "s3" {
    bucket         = "vite-aws-terraform"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "vite-aws-terraform-locks"
    encrypt        = true
  }
  required_version = ">= 1.1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_s3_bucket" "vite_aws_website_bucket" {
  bucket = "vite-aws-website-bucket"
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}


resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.vite_aws_website_bucket.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = [
          aws_s3_bucket.vite_aws_website_bucket.arn,
          "${aws_s3_bucket.vite_aws_website_bucket.arn}/*",
        ]
      },
    ]
  })
}
