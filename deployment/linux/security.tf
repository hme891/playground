resource "aws_security_group" "nginx" {
  vpc_id = var.vpc_id

  tags = {
    Name       = "${var.app_name}.${var.vpc_name}.${var.cluster}.${var.domain}"
    Deployment = "${var.app_name}"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
