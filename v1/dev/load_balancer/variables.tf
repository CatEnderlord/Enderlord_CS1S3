variable "region" {
  default = "eu-central-1"
}

variable "profile" {
  default = "default"
}

variable "env" {
  default = "dev"
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}
