variable "region" {
  default = "eu-central-1"
}

variable "profile" {
  default = "default"
}

variable "env" {
  default = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}

variable "cpu_high_threshold" {
  description = "CPU threshold for scaling up"
  type        = number
  default     = 70
}

variable "cpu_low_threshold" {
  description = "CPU threshold for scaling down"
  type        = number
  default     = 20
}

variable "admin_ip" {
  description = "Admin IP for SSH access"
  type        = string
  default     = "0.0.0.0/0"  # Default allows all - CHANGE THIS for production!
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
