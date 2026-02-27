terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.33.0"
    }
  }
}

locals {
  public_key_material = var.enable_ssh ? file(pathexpand(var.public_key_path)) : "unused"
}

resource "aws_key_pair" "this" {
  count      = var.enable_ssh ? 1 : 0
  key_name   = var.key_name
  public_key = local.public_key_material
}

resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.enable_ssh ? var.key_name : null

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-web"
    }
  )

  user_data = templatefile("${path.module}/bootstrap.sh", {
    environment = var.environment
  })
}
