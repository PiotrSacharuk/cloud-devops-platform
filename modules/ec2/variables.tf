variable "instance_type" {}
variable "subnet_id" {}
variable "security_group_id" {}
variable "key_name" {}
variable "ami_id" {}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "common_tags" {
  type = map(string)
}

variable "public_key_path" {
  description = "Path to the public key for EC2 key pair"
  type        = string
}

variable "enable_ssh" {
  type    = bool
  default = true
}
