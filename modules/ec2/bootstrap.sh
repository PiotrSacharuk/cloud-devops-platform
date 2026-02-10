#!/bin/bash
set -e

# basic system update
yum update -y

# install packages
amazon-linux-extras install -y nginx1
yum install -y python3 git

# simple placeholder app
echo "It works - environment: ${environment}" > /usr/share/nginx/html/index.html

systemctl enable nginx
systemctl start nginx