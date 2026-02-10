provider "aws" {
  region = var.aws_region
}

module "network" {
  source           = "../../modules/network"
  environment      = "dev"
  allowed_ssh_cidr = var.allowed_ssh_cidr
  aws_region       = var.aws_region
}

module "web" {
  source            = "../../modules/ec2"
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = module.network.subnet_id
  security_group_id = module.network.security_group_id
  key_name          = var.key_name
  environment       = "dev"
}
