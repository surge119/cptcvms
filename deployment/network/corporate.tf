locals {
  corporate_vms = [
    {
      name       = "adcs"
      ami        = data.aws_ami.cptc-corp-payment-web.image_id
      private_ip = "10.0.0.6"
    }
  ]
  corporate_instances = [
    for vm in local.corporate_vms :
    {
      name          = vm.name
      ami           = vm.ami
      instance_type = local.cptc8_instance
      subnet_id     = module.network.corporate_subnet_id
      private_ip    = vm.private_ip
      public_ip     = false
      ports = [
        {
          port        = 0
          protocol    = "-1"
          cidr_blocks = [local.vpc_cidr]
        }
      ]
    }
  ]
}

data "aws_ami" "cptc-corp-adcs" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["adcs"]
  }
}

data "aws_ami" "cptc-corp-dc01" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["dc01"]
  }
}

data "aws_ami" "cptc-corp-doapi" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["doapi"]
  }
}

data "aws_ami" "cptc-corp-hms" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["hms"]
  }
}

data "aws_ami" "cptc-corp-kiosk01" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["kiosk01"]
  }
}

data "aws_ami" "cptc-corp-kiosk02" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["kiosk02"]
  }
}

data "aws_ami" "cptc-corp-kiosk03" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["kiosk03"]
  }
}

data "aws_ami" "cptc-corp-kiosk04" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["kiosk04"]
  }
}

data "aws_ami" "cptc-corp-ldap" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["ldap"]
  }
}

data "aws_ami" "cptc-corp-lps" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["lps"]
  }
}

data "aws_ami" "cptc-corp-media" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["media"]
  }
}

data "aws_ami" "cptc-corp-payment-db" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["payment-db"]
  }
}

data "aws_ami" "cptc-corp-payment-web" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["payment-web"]
  }
}

data "aws_ami" "cptc-corp-profiler" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["profiler"]
  }
}

data "aws_ami" "cptc-corp-workstation01" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["workstation01"]
  }
}

data "aws_ami" "cptc-corp-workstation02" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["workstation02"]
  }
}
