terraform {
  backend "s3" {
    bucket         = "cloud-devops-platform-free-tier"
    key            = "cloud-devops-platform/staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
