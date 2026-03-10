variable "region" {
    default = "eu-central-1"   
}
variable "profile" {
    default = "default"
}
variable "vpc_cidr_block" {
    default = "10.0.0.0/19"
}
variable "enable_dns_support" {
    default = false
}
variable "enable_dns_hostnames" {
    default = false
}
variable "env" {
    default = "dev"
}
