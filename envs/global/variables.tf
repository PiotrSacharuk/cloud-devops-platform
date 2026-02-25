variable "aws_region" {
  description = "AWS region to deploy resources in (e.g. us-east-1)"
  type        = string
}

variable "alert_email" {
  type        = string
  description = "The email address to receive billing alerts."
}

variable "billing_threshold" {
  type        = string
  description = "The billing threshold in USD that triggers the alert."
  default     = "1.0"
}
