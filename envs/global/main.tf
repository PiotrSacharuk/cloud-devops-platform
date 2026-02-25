provider "aws" {
  region = var.aws_region
}

module "billing_alarm" {
  source            = "../../modules/billing_alarm"
  alert_email       = var.alert_email
  billing_threshold = var.billing_threshold
}
