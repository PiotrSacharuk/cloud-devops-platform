variable "aws_region" {}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into dev EC2"
  type        = string
}

variable "ami_id" {}

variable "instance_type" {}

variable "key_name" {}

variable "public_key_path" {}

variable "enable_ssh" {}

variable "environment" {
  type = string
}
