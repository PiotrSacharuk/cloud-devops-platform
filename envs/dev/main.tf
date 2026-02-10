provider "aws" {
  region = var.aws_region
}

module "network" {
  source     = "../../modules/network"
  aws_region = var.aws_region
  ssh_cidr   = var.ssh_cidr
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
