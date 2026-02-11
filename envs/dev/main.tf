locals {
  common_tags = {
    Project     = "cloud-devops-platform"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source           = "../../modules/network"
  environment      = var.environment
  common_tags      = local.common_tags
  allowed_ssh_cidr = var.allowed_ssh_cidr
  aws_region       = var.aws_region
}

module "web" {
  source            = "../../modules/ec2"
  environment       = var.environment
  common_tags       = local.common_tags
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = module.network.subnet_id
  security_group_id = module.network.security_group_id
  key_name          = var.key_name
}
