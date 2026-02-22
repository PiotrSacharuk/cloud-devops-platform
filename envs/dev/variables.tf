variable "aws_region" {
  type = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into dev EC2"
  type        = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "public_key_path" {
  type = string
}

variable "enable_ssh" {
  type = bool
}

variable "environment" {
  type = string
}
