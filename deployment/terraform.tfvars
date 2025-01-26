# credentials configure 
access_key = "******"
secret_key = "******"
region     = "ap-northeast-1"

## app configuration. You can use a separate tf file to save them.
cluster  = "dev"
domain   = "emin-test.com"
vpc_cidr = "10.0.0.0/16"
vpc_name = "emin-vpc"
app_name = "nginx"
nginx_instane_config = {
  root_volume_type          = "gp2"
  root_volume_size          = "10"
  max_size                  = "1"
  min_size                  = "1"
  health_check_grace_period = "300"
  instance_type             = "t2.micro"
  desired_capacity          = 1
  placement_tenancy         = "default"
}
