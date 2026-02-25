module "billing_alarm" {
  source            = "../../modules/billing_alarm"
  alert_email       = var.alert_email
  billing_threshold = var.billing_threshold
}

#################################
# S3 Backend Security Hardening
#################################
resource "aws_s3_bucket_public_access_block" "backend" {
  bucket = "cloud-devops-platform-free-tier"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "backend" {
  bucket = "cloud-devops-platform-free-tier"

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend" {
  bucket = "cloud-devops-platform-free-tier"

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
