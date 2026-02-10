output "web_public_ip" {
  description = "Public IP of the web server"
  value       = module.web.public_ip
}
