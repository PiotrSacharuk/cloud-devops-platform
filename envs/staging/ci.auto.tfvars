aws_region  = "us-east-1"
environment = "staging"

ami_id        = "ami-0c02fb55956c7d316"
instance_type = "t3.micro"

# CI does not need SSH access, so we disable it here
allowed_ssh_cidr = "127.0.0.1/32"
