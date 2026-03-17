output "vpc_id" {
    description = "VPC id."
    value = aws_vpc.main.id
}

output "ec2_sg_id" {
    description = "EC2 security group ID for RDS access"
    value = aws_security_group.ec2_sg.id
}

output "grafana_sg_id" {
    description = "Grafana security group ID for RDS access"
    value = aws_security_group.grafana_sg.id
}

output "bastion_public_ip" {
  description = "Bastion host public IP for SSH access"
  value       = aws_instance.bastion.public_ip
}

output "bastion_instance_id" {
  description = "Bastion EC2 instance ID"
  value       = aws_instance.bastion.id
}

output "bastion_sg_id" {
  description = "Bastion security group ID"
  value       = aws_security_group.bastion_sg.id
}

output "grafana_private_ip" {
  description = "Grafana instance private IP (access via bastion)"
  value       = aws_instance.grafana.private_ip
}

output "grafana_access_url" {
  description = "Access Grafana via bastion tunnel: ssh -J ec2-user@BASTION_IP ec2-user@GRAFANA_IP -L 3000:localhost:3000"
  value       = "Bastion: ${aws_instance.bastion.public_ip} -> Grafana: ${aws_instance.grafana.private_ip}:${var.grafana_port}"
}

output "grafana_instance_id" {
  description = "Grafana EC2 instance ID"
  value       = aws_instance.grafana.id
}

output "app_instance_id" {
  description = "App EC2 instance ID"
  value       = aws_instance.app.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for database"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_route_table_id" {
  description = "Private route table ID for NAT Gateway route"
  value       = aws_route_table.private.id
}

output "db_username" {
  description = "Database username"
  value       = var.db_username
}

