
variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "app_name" {}
variable "vpc_name" {}
variable "deployment_id" {
  default = 1
}
variable "domain" {}
variable "cluster" {}

variable "deployment_type" {
  default = ""
}

variable "nginx_instane_config" {
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

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
