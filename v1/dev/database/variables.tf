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
    default = "Enderlord123!"
    sensitive = true
}