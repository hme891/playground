
resource "aws_elb" "nginx" {
  name     = "${var.app_name}-alb"
  internal = false
  #subnets = flatten(aws_subnet.nginx.*.id)
  subnets = [var.public_subnet]
  # load_balancer_type = "network"
  listener {
    instance_port      = 443
    instance_protocol  = "https"
    ssl_certificate_id = var.ssl_certificate_id
    lb_port            = 443
    lb_protocol        = "https"
  }
  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }
  health_check {
    healthy_threshold   = 2
    interval            = 30
    target              = "tcp:80"
    timeout             = 3
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.app_name}.${var.vpc_name}.${var.cluster}.${var.domain}"
  }

  security_groups = ["${aws_security_group.nginx.id}"]
}

resource "aws_proxy_protocol_policy" "proxy-policy" {
  load_balancer  = aws_elb.nginx.name
  instance_ports = ["443"]
}

resource "aws_route53_zone" "nginx_zone" {
  name = var.domain
}
resource "aws_route53_record" "nginx" {
  name    = "${var.app_name}.${var.vpc_name}.${var.cluster}.${var.domain}"
  type    = "A"
  zone_id = aws_route53_zone.nginx_zone.zone_id

  alias {
    name                   = aws_elb.nginx.dns_name
    zone_id                = aws_elb.nginx.zone_id
    evaluate_target_health = false
  }
}
