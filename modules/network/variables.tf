variable "aws_region" {
  type = string
}

variable "public_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH (e.g. 1.2.3.4/32)"
  type        = string
}

variable "environment" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "enable_ssh" {
  description = "Whether to allow inbound SSH (22) to the web security group"
  type        = bool
  default     = false
}
