variable "aws_region" {
  type = string
}

variable "public_cidr" {
  default = "10.0.1.0/24"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "availability_zone" {
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
