variable "instance_type" {}
variable "subnet_id" {}
variable "security_group_id" {}
variable "key_name" {}
variable "ami_id" {}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}
