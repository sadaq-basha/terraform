resource "random_id" "tfstate_suffix" {
  byte_length = 2
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "ls-terraform-state-${random_id.tfstate_suffix.hex}"
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

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls   = true
  block_public_policy = true
}