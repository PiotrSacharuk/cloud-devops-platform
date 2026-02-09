terraform {
  backend "s3" {
    bucket         = "cloud-devops-platform-free-tier"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
