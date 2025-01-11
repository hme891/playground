resource "tls_private_key" "nginx" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "nginx_key" {
  key_name   = "${var.app_name}-key"
  public_key = tls_private_key.nginx.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.nginx.private_key_pem}' > aws_keys_pairs.pem
      chmod 400 aws_keys_pairs.pem
    EOT
  }


}



