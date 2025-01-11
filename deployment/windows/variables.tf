variable "vpc_id" {}
variable "vpc_cidr" {}
variable "deployment_id" {}
variable "region" {}
variable "ami_id" {}
variable "placement_tenancy" {}
variable "cluster" {}
variable "domain" {}
variable "ssh_key_name" {}
variable "ssl_certificate_id" {}
variable "vpc_name" {}
data "aws_availability_zones" "available" {}
variable "instance_type" {}
variable "root_volume_type" {}
variable "instance_profile_name"  {}
variable "root_volume_size" {}
 
 
 
variable "app_name" {}
variable "windows_ami_id" {}
variable "public_subnet" {}
variable "private_subnet" {}