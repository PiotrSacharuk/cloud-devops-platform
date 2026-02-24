output "web_instance_id" {
  description = "The ID of the web EC2 instance"
  value       = module.web.instance_id
}

output "web_private_ip" {
  description = "The private IP of the web EC2 instance"
  value       = module.web.private_ip
}
