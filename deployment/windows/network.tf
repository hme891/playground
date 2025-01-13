resource "aws_subnet" "nginx" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + length(data.aws_availability_zones.available.names) * var.deployment_id)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = count.index == 0 ? true : false # set the first subnet as public subnets for internet access
  tags = {
    Name       = "nginx-subnet-${count.index}"
    Deployment = "${var.app_name}"
  }
}
