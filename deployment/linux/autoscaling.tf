data "template_file" "cv_user_data" {
  template = file("${path.module}/templates/linux_user_data.sh")
}

resource "aws_launch_configuration" "nginx_lc" {
  name_prefix          = "${var.app_name}.linux.${var.cluster}.${var.domain}-"
  image_id             = var.ami_id
  instance_type        = var.instance_type
  placement_tenancy    = var.placement_tenancy
  key_name             = var.ssh_key_name
  iam_instance_profile = var.instance_profile_name
  user_data            = data.template_file.cv_user_data.rendered
  security_groups      = ["${aws_security_group.nginx.id}"]

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
  count                = 1
  name_prefix          = "${var.app_name}.linux.${var.cluster}.${var.domain}-"
  launch_configuration = aws_launch_configuration.nginx_lc.name
  max_size             = var.max_size
  min_size             = var.min_size
  desired_capacity     = var.desired_capacity
  vpc_zone_identifier  = [var.private_subnet]
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
