aws_region  = "us-east-1"
environment = "dev"

ami_id        = "ami-0c02fb55956c7d316"
instance_type = "t2.micro"

# CI does not need SSH access, so we disable it here
enable_ssh       = false
key_name         = ""
public_key_path  = ""
allowed_ssh_cidr = "127.0.0.1/32"

alert_email = "ci-dummy@example.com"
