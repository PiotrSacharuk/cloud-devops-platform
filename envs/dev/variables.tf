variable "aws_region" {
  description = "AWS region to deploy resources in (e.g. us-east-1)"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into dev EC2"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (e.g. t2.micro)"
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 key pair to use for SSH access"
  type        = string
}

variable "public_key_path" {
  description = "Path to the public key for EC2 key pair"
  type        = string
}

variable "enable_ssh" {
  description = "Whether to allow SSH access to the EC2 instance"
  type        = bool
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "alert_email" {
  description = "Email address to receive billing alerts"
  type        = string
}

variable "billing_threshold" {
  description = "Billing threshold in USD that triggers the alert"
  type        = string
  default     = "1.0"
}
