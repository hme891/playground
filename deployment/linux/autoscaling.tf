data "template_file" "cv_user_data" {
  template = file("${path.module}/templates/linux_user_data.sh")
}

resource "aws_launch_configuration" "nginx_lc" {
  name_prefix          = "${var.app_name}.linux.${var.cluster}.${var.domain}-"
  image_id             = data.aws_ami.ec2_ami.id
  instance_type        = var.instance_type
  placement_tenancy    = var.placement_tenancy
  key_name             = data.aws_key_pair.ec2.key_name
  iam_instance_profile = data.aws_iam_instance_profile.instance_profile.name
  user_data            = data.template_file.cv_user_data.rendered
  security_groups      = data.aws_security_groups.app_sg.ids

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "nginx_linux_asg" {
  name_prefix          = "${var.app_name}.linux.${var.cluster}.${var.domain}-"
  launch_configuration = aws_launch_configuration.nginx_lc.name
  max_size             = var.max_size
  min_size             = var.min_size
  desired_capacity     = var.desired_capacity
  vpc_zone_identifier  = data.aws_subnets.private-subnet.ids
  load_balancers       = ["${aws_elb.nginx.name}"]
  tag {
    key                 = "Name"
    value               = "${var.app_name}.linux.${var.cluster}.${var.domain}"
    propagate_at_launch = true
  }
  tag {
    key                 = "platform"
    value               = "linux"
    propagate_at_launch = true
  }
  tag {
    key                 = "Deployment"
    value               = var.app_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
