
variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "app_name" {}
variable "vpc_name" {}
variable "ami_id" {
  default = "ami-xxxx"
}
variable "windows_ami_id" {
  default = "ami-xxx"
}
variable "deployment_id" {}
variable "domain_name" {}
variable "cluster" {}
variable "nginx" {
  default = {
    root_volume_type          = "gp2"
    root_volume_size          = "10"
    max_size                  = "1"
    min_size                  = "1"
    health_check_grace_period = "300"
    instance_type             = "t2.micro"
    desired_capacity          = 1
    placement_tenancy         = "default"
  }
}
variable "nginx_windows" {
  default = {
    root_volume_type          = "gp2"
    root_volume_size          = "60"
    health_check_grace_period = "300"
    instance_type             = "t2.medium"
    placement_tenancy         = "default"
  }
}
variable "platform" {
  default = "linux"
}
variable "vpc_cidr" {}
