provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

terraform {
  backend "local" {
  }
}

module "bootstrap" {
  count    = var.deployment_type == "bootstrap" ? 1 : 0
  source   = "./bootstrap"
  cluster  = var.cluster
  domain   = var.domain
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  app_name = var.app_name

}

module "linux" {
  count             = var.deployment_type == "linux" ? 1 : 0
  source            = "./linux"
  cluster           = var.cluster
  region            = var.region
  deployment_id     = var.deployment_id
  domain            = var.domain
  placement_tenancy = lookup(var.nginx_instane_config, "placement_tenancy")
  vpc_name          = var.vpc_name
  instance_type     = lookup(var.nginx_instane_config, "instance_type")
  root_volume_type  = lookup(var.nginx_instane_config, "root_volume_type")
  root_volume_size  = lookup(var.nginx_instane_config, "root_volume_size")
  max_size          = lookup(var.nginx_instane_config, "max_size")
  min_size          = lookup(var.nginx_instane_config, "min_size")
  desired_capacity  = lookup(var.nginx_instane_config, "desired_capacity")
  app_name          = var.app_name
}

module "windows" {
  count             = var.deployment_type == "windows" ? 1 : 0
  source            = "./windows"
  cluster           = var.cluster
  region            = var.region
  domain            = var.domain
  placement_tenancy = lookup(var.nginx_instane_config, "placement_tenancy")
  vpc_name          = var.vpc_name
  instance_type     = lookup(var.nginx_instane_config, "instance_type")
  root_volume_type  = lookup(var.nginx_instane_config, "root_volume_type")
  root_volume_size  = lookup(var.nginx_instane_config, "root_volume_size")
  app_name          = var.app_name
}
