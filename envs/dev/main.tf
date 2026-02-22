terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.31.0"
    }
  }
}

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
  enable_ssh       = true
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
  public_key_path   = var.public_key_path
  enable_ssh        = var.enable_ssh
}
