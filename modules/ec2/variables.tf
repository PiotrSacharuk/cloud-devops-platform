variable "instance_type" {
  description = "EC2 instance type (e.g. t2.micro)"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID to attach to the EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "Amazon Machine Image (AMI) ID for the EC2 instance"
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
  description = "Whether to enable SSH access to the EC2 instance"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "Name of the EC2 key pair to use for SSH access (required when enable_ssh=true)"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.enable_ssh ? var.key_name != null && var.key_name != 0 : true
    error_message = "When enable_ssh=true you must set key_name."
  }
}

variable "public_key_path" {
  description = "Path to the public key for EC2 key pair"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.enable_ssh ? var.public_key_path != null && var.public_key_path != "" : true
    error_message = "When enable_ssh=true you must set public_key_path."
  }
}
