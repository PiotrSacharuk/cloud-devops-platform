variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "public_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
  default     = "us-east-1a"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH (e.g. 1.2.3.4/32)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

variable "enable_ssh" {
  description = "Whether to allow inbound SSH (22) to the web security group"
  type        = bool
  default     = false
}
