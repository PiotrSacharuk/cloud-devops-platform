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

variable "environment" {
  type = string
}
