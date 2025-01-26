deployment_type = "windows"
nginx_instane_config = {
  root_volume_type          = "gp2"
  root_volume_size          = "60"
  health_check_grace_period = "300"
  instance_type             = "t2.medium"
  placement_tenancy         = "default"
}
