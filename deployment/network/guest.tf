locals {
  guest_vms = [
    {
      name       = "kiosk01"
      ami        = data.aws_ami.cptc-corp-kiosk01.id
      private_ip = "10.0.200.101"
    },
    {
      name       = "kiosk02"
      ami        = data.aws_ami.cptc-corp-kiosk02.id
      private_ip = "10.0.200.102"
    },
    {
      name       = "kiosk03"
      ami        = data.aws_ami.cptc-corp-kiosk03.id
      private_ip = "10.0.200.103"
    },
    {
      name       = "kiosk04"
      ami        = data.aws_ami.cptc-corp-kiosk04.id
      private_ip = "10.0.200.104"
    }
  ]
  guest_instances = [
    for vm in local.guest_vms :
    {
      name          = vm.name
      ami           = vm.ami
      instance_type = local.cptc8_instance
      subnet_id     = aws_subnet.subnets["guest"].id
      private_ip    = vm.private_ip
      public_ip     = false
      volume_size   = 50
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

data "aws_ami" "cptc-corp-kiosk01" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "name"
    values = ["cptc8-kiosk01"]
  }
}

data "aws_ami" "cptc-corp-kiosk02" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "name"
    values = ["cptc8-kiosk02"]
  }
}

data "aws_ami" "cptc-corp-kiosk03" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "name"
    values = ["cptc8-kiosk03"]
  }
}

data "aws_ami" "cptc-corp-kiosk04" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "name"
    values = ["cptc8-kiosk04"]
  }
}
