
# locals {
#   certificate =   file("./certs/server.crt")
#   private_key =   file("./certs/server.rsa")
# }


resource "aws_acm_certificate" "cert" {
  private_key      = file("./certs/server.rsa") #locals.certificate
  certificate_body = file("./certs/server.crt") #locals.private_key
  tags = {
    Name = "emin-certificate"
  }
}
