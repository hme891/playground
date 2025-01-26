resource "aws_elb" "nginx" {
  name      = "${var.app_name}-alb"
  internal  = false
  subnets   = data.aws_subnets.public-subnet.ids
  instances = [aws_instance.ec2.id]
  listener {
    instance_port      = 443
    instance_protocol  = "https"
    ssl_certificate_id = data.aws_acm_certificate.acm.id
    lb_port            = 443
    lb_protocol        = "https"
  }

  health_check {
    healthy_threshold   = 2
    interval            = 30
    target              = "HTTPS:443/"
    timeout             = 3
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.app_name}.${var.vpc_name}.${var.cluster}.${var.domain}"
  }

  security_groups = data.aws_security_groups.app_sg.ids
}
resource "aws_proxy_protocol_policy" "proxy-policy" {
  load_balancer  = aws_elb.nginx.name
  instance_ports = ["443"]
}
