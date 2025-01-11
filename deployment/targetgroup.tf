# resource "aws_lb_target_group" "nginx_tg" {
#   name     = "nginx_tg"
#   port     = 443
#   protocol = "HTTPS"
#   vpc_id   = aws_vpc.main_vpc.id
# }
