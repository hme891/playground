data "template_file" "windows_user_data" {
  template = file("${path.module}/templates/windows_user_data.ps1")
}

resource "aws_instance" "ec2" {
  ami                    = var.windows_ami_id
  instance_type          = var.instance_type
  iam_instance_profile   = var.instance_profile_name
  subnet_id              = var.private_subnet
  vpc_security_group_ids = ["${aws_security_group.nginx.id}"]
  ebs_optimized          = true
  root_block_device {
    volume_size = 60
  }
  monitoring = false
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  user_data                   = data.template_file.windows_user_data.rendered
  associate_public_ip_address = false
  tags = {
    platform            = "windows"
    Name                = "nginx-windows-ec2"
    propagate_at_launch = true
  }

}
