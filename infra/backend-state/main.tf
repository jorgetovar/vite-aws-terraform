# CREATE AN S3 BUCKET AND DYNAMODB TABLE TO USE AS A TERRAFORM BACKEND
terraform {
  required_version = ">= 1.1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 4.0"
    }
  }
}


# CONFIGURE OUR AWS CONNECTION
provider "aws" {
  region = "us-east-1"
}

# CREATE THE S3 BUCKET
resource "aws_s3_bucket" "terraform_state" {
  bucket = "vite-aws-terraform"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# AVOID PUBLIC ACCESS
resource "aws_s3_bucket_public_access_block" "terraform_state_policy" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CREATE THE DYNAMODB TABLE
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "vite-aws-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}