resource "aws_security_group" "nginx" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name       = "${var.app_name}.${var.vpc_name}.${var.cluster}"
    Deployment = "${var.app_name}"
    Platform   = "linux"
  }
  #  alternatively, use the aws_vpc_security_group_egress_rule and aws_vpc_security_group_ingress_rule 
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = all
  }
}
