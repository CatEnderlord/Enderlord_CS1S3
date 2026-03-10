output "vpc_id" {
    description = "VPC id."
    value = aws_vpc.main.id
}

output "grafana_access_url" {
  description = "The public URL to access the Grafana dashboard"
  value       = "http://${aws_instance.grafana.public_ip}:${var.grafana_port}"
}

output "private_subnet_ids" {
  description = "Private subnet IDs for database"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}