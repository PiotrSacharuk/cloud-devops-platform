resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.dev_key.key_name

  tags = { Name = "dev-web" }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y nginx1
              yum install -y python3 git
              echo "It works" > /var/www/html/index.html
              systemctl enable nginx
              systemctl start nginx
              EOF
}

resource "aws_key_pair" "dev_key" {
  key_name   = var.key_name
  public_key = file("~/.ssh/devops-dev.pub")
}
