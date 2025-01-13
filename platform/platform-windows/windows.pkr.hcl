packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.6"
      source  = "github.com/hashicorp/amazon"
    }
    window-update = {
      version = ">= 0.15.0"
      source  = "github.com/rgl/windows-update"
    }
    ansible = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/ansible"
    }
  }
}
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "user_password" {
  type    = string
  default = "SuperS3cr3t!!!!"
}



source "amazon-ebs" "firstrun-windows" {
  ami_name     = "windows-nginx-${local.timestamp}"
  communicator = "winrm"
  region       = var.region
  source_ami_filter {  
    filters = {
      name                = "Windows_Server-2022*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  spot_instance_types      = ["t2.medium"]
  spot_price               = "auto"
  ssh_timeout              = "10m"
  ssh_username             = "Administrator"
  ssh_file_transfer_method = "sftp"
  pause_before_connecting  = "1m"
  user_data_file           = "./bootstrap_win.ps1"
  winrm_password           = "SuperS3cr3t!!!!"
  winrm_username           = "Administrator"
  winrm_port               = "5986"
  winrm_use_ssl            = "true"
  winrm_insecure           = "true"
  winrm_use_ntlm           = "true"
}


build {
  name    = "learn-packer"
  sources = ["source.amazon-ebs.firstrun-windows"]

  provisioner "windows-restart" {
  }
  provisioner "powershell" {
    script = "files/InstallChoco.ps1"
  }
  provisioner "ansible" {
    playbook_file = "./install-nginx.yml"
    use_proxy     = false
    extra_arguments = [
      "--connection", "packer", "--extra-vars", "ansible_python_interpreter='C:\\ProgramData\\chocolatey\\bin\\python3.12.exe' ansible_ssh_timeout=600 ansible_winrm_scheme=https ansible_winrm_server_cert_validation=ignore ansible_connection=winrm ansible_port=5986 ansible_user=Administrator ansible_password=SuperS3cr3t!!!!"
    ]
  }
  post-processors {
    post-processor "manifest" {
      output = "ami.json"
    }

  }
}
