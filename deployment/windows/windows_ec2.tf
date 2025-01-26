data "template_file" "windows_user_data" {
  template = file("${path.module}/templates/windows_user_data.ps1")
}

resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ec2_ami.id
  instance_type          = var.instance_type
  iam_instance_profile   = data.aws_iam_instance_profile.instance_profile.name
  subnet_id              = data.aws_subnet.private-subnet.id
  vpc_security_group_ids = data.aws_security_groups.app_sg.ids
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
