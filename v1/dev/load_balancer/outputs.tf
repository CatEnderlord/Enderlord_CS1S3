output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB Zone ID"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.app.arn
}

output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb_sg.id
}

output "alb_url" {
  description = "ALB URL"
  value       = "http://${aws_lb.main.dns_name}"
}

output "grafana_url" {
  description = "Grafana URL - Access via SSH tunnel (see grafana_tunnel_command)"
  value       = "Use SSH tunnel to access Grafana - see grafana_tunnel_command output"
}

output "grafana_tunnel_command" {
  description = "SSH tunnel command to access Grafana"
  value       = "Run this command, then open http://localhost:3000 in your browser"
}

output "grafana_target_group_arn" {
  description = "Grafana Target Group ARN"
  value       = aws_lb_target_group.grafana.arn
}
