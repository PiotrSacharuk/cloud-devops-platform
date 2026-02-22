variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "common_tags" {
  type = map(string)
}

variable "enable_ssh" {
  type    = bool
  default = false
}

variable "key_name" {
  type     = string
  default  = null
  nullable = true

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
