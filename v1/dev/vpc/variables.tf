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
variable "allowed_cidr" {
  description = "CIDR block allowed to access Grafana and SSH"
  type        = string
  default     = "0.0.0.0/0"
}