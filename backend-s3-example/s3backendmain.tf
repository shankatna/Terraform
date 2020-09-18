
provider "aws" {
  region = "ca-central-1"
  profile = "aws-shan"
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    profile         = "aws-shan"
    #shared_credentials_file = "~/.aws/credentials"
    bucket         = "terraform-s3-backend-eg"
    key            = "global/s3/terraform.tfstate"
    region         = "ca-central-1"
    # Replace this with your DynamoDB table name!
    #dynamodb_table = "terraform-backend-eg-bg"
    encrypt        = true
  }
}



resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-s3-backend-eg"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-backend-eg-bg"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
