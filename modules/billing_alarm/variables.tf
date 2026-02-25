variable "alert_email" {
  type        = string
  description = "The email address to receive billing alerts."
}

variable "billing_threshold" {
  type        = string
  description = "The billing threshold in USD that triggers the alert."
  default     = "1.0"
}
