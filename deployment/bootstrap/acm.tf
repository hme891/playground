resource "aws_acm_certificate" "cert" {
  private_key      = file("./certs/server.rsa")
  certificate_body = file("./certs/server.crt")
  tags = {
    Name = "emin-certificate"
  }
}
