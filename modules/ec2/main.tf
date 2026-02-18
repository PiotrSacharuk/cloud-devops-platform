resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.dev_key.key_name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
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

resource "aws_key_pair" "dev_key" {
  key_name   = var.key_name
  public_key = file("~/.ssh/devops-dev.pub")
}
