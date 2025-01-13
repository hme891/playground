
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

terraform {
  backend "local" {
  }
}

module "linux" {
  count                 = var.platform == "linux" ? 1 : 0
  source                = "./linux"
  cluster               = var.cluster
  region                = var.region
  deployment_id         = var.deployment_id
  domain                = var.domain_name
  placement_tenancy     = lookup(var.nginx, "placement_tenancy")
  ami_id                = var.ami_id
  ssh_key_name          = aws_key_pair.nginx_key.key_name
  vpc_cidr              = var.vpc_cidr
  vpc_id                = aws_vpc.main_vpc.id
  vpc_name              = var.vpc_name
  instance_type         = lookup(var.nginx, "instance_type")
  root_volume_type      = lookup(var.nginx, "root_volume_type")
  root_volume_size      = lookup(var.nginx, "root_volume_size")
  max_size              = lookup(var.nginx, "max_size")
  min_size              = lookup(var.nginx, "min_size")
  desired_capacity      = lookup(var.nginx, "desired_capacity")
  app_name              = var.app_name
  public_subnet         = aws_subnet.public_subnet.id
  private_subnet        = aws_subnet.private_subnet.id
  ssl_certificate_id    = aws_acm_certificate.cert.arn
  instance_profile_name = aws_iam_instance_profile.nginx_access_profile.name
}


module "windows" {
  count                 = var.platform == "windows" ? 1 : 0
  source                = "./windows"
  cluster               = var.cluster
  region                = var.region
  deployment_id         = var.deployment_id
  domain                = var.domain_name
  placement_tenancy     = lookup(var.nginx_windows, "placement_tenancy")
  ami_id                = var.ami_id
  ssh_key_name          = aws_key_pair.nginx_key.key_name
  vpc_cidr              = var.vpc_cidr
  vpc_id                = aws_vpc.main_vpc.id
  vpc_name              = var.vpc_name
  instance_type         = lookup(var.nginx_windows, "instance_type")
  root_volume_type      = lookup(var.nginx_windows, "root_volume_type")
  root_volume_size      = lookup(var.nginx_windows, "root_volume_size")
  app_name              = var.app_name
  windows_ami_id        = var.windows_ami_id
  public_subnet         = aws_subnet.public_subnet.id
  private_subnet        = aws_subnet.private_subnet.id
  ssl_certificate_id    = aws_acm_certificate.cert.arn
  instance_profile_name = aws_iam_instance_profile.nginx_access_profile.name
}
