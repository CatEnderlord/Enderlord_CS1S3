output "sns_topic_arn" {
  description = "SNS Topic ARN for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "app_log_group_name" {
  description = "Application CloudWatch Log Group name"
  value       = aws_cloudwatch_log_group.app_logs.name
}

output "grafana_log_group_name" {
  description = "Grafana CloudWatch Log Group name"
  value       = aws_cloudwatch_log_group.grafana_logs.name
}

output "alarm_names" {
  description = "List of all CloudWatch alarm names"
  value = [
    aws_cloudwatch_metric_alarm.rds_cpu_high.alarm_name,
    aws_cloudwatch_metric_alarm.rds_storage_low.alarm_name,
    aws_cloudwatch_metric_alarm.rds_connections_high.alarm_name,
    aws_cloudwatch_metric_alarm.rds_memory_low.alarm_name,
    aws_cloudwatch_metric_alarm.alb_unhealthy_hosts.alarm_name,
    aws_cloudwatch_metric_alarm.alb_response_time.alarm_name,
    aws_cloudwatch_metric_alarm.alb_5xx_errors.alarm_name,
    aws_cloudwatch_metric_alarm.grafana_status_check.alarm_name,
    aws_cloudwatch_metric_alarm.grafana_cpu_high.alarm_name
  ]
}
