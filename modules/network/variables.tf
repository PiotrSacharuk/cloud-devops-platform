variable "aws_region" {}
variable "public_cidr" {
  default = "10.0.1.0/24"
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "availability_zone" {
  default = "us-east-1a"
}
variable "ssh_cidr" {}
