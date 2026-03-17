variable "region" {
    default = "eu-central-1"   
}
variable "profile" {
    default = "default"
}
variable "env" {
    default = "dev"
}
variable "db_username" {
    default = "admin"
}
variable "db_password" {
    type        = string
    sensitive   = true
    description = "RDS password - provide via TF_VAR_db_password or terraform apply prompt"
    default     = "ADMIN123"  # Default for testing - change in production
}
variable "admin_ip" {
  description = "Admin IP for direct RDS access"
  type        = string
  default     = "0.0.0.0/0"
}
