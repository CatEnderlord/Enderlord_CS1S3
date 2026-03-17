variable "region" {
    default = "eu-central-1"   
}
variable "profile" {
    default = "default"
}
variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
}
variable "enable_dns_support" {
    default = true
}
variable "enable_dns_hostnames" {
    default = true
}
variable "env" {
    default = "dev"
}
variable "grafana_port" {
  description = "Port for Grafana web interface"
  type        = number
  default     = 3000
}
variable "ssh_port" {
  description = "SSH port"
  type        = number
  default     = 22
}
variable "admin_ip" {
  description = "Your IP address for SSH and Grafana access (e.g., 203.0.113.0/32)"
  type        = string
  default     = "0.0.0.0/0"  # Default allows all - CHANGE THIS for production!
  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}/\\d{1,2}$", var.admin_ip))
    error_message = "admin_ip must be a valid CIDR block (e.g., 203.0.113.0/32)"
  }
}
variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "ADMIN123"  # Default for testing - change in production
}
