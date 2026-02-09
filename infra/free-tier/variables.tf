variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "public_ip" {
  type        = string
  description = "Your public ip for SSH access"
}

variable "key_name" {
  type        = string
  description = "SSH key pair name to attach to EC2"
}
