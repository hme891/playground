data "aws_subnets" "public-subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.app_vpc.id]
  }

  tags = {
    Owner = "emin"
    Name  = "nginx-public-subnet"
  }
}

data "aws_subnet" "private-subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.app_vpc.id]
  }

  tags = {
    Owner = "emin"
    Name  = "nginx-private-subnet"
  }
}

data "aws_acm_certificate" "acm" {
  statuses = ["ISSUED"]
  tags = {
    Name = "emin-certificate"
  }
}

data "aws_iam_instance_profile" "instance_profile" {
  name = "${var.app_name}.${var.vpc_name}.${var.cluster}.${var.domain}"
}

data "aws_vpc" "app_vpc" {
  tags = {
    Name = "${var.vpc_name}"
  }
}

data "aws_ami" "ec2_ami" {
  most_recent = true
  name_regex  = "^${var.app_name}-windows"
  owners      = ["self"]
}

data "aws_security_groups" "app_sg" {
  tags = {
    Name = "${var.app_name}.${var.vpc_name}.${var.cluster}"
  }
}
