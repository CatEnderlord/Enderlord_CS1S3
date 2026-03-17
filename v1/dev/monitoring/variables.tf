variable "region" {
  default = "eu-central-1"
}

variable "profile" {
  default = "default"
}

variable "env" {
  default = "dev"
}

variable "alert_email" {
  description = "Email address for CloudWatch alerts (leave empty to skip email subscription)"
  type        = string
  default     = ""
}

variable "rds_cpu_threshold" {
  description = "RDS CPU utilization threshold (%)"
  type        = number
  default     = 80
}

variable "rds_storage_threshold" {
  description = "RDS free storage threshold (bytes)"
  type        = number
  default     = 2000000000  # 2GB
}

variable "rds_connections_threshold" {
  description = "RDS database connections threshold"
  type        = number
  default     = 80
}

variable "rds_memory_threshold" {
  description = "RDS freeable memory threshold (bytes)"
  type        = number
  default     = 256000000  # 256MB
}

variable "alb_response_time_threshold" {
  description = "ALB target response time threshold (seconds)"
  type        = number
  default     = 2
}

variable "alb_5xx_threshold" {
  description = "ALB 5XX error count threshold"
  type        = number
  default     = 10
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period (days)"
  type        = number
  default     = 7
}
