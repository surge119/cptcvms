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
  image_id    = "ami-096a2e1a6ec5012ba"
}

data "aws_ami" "cptc-corp-kiosk02" {
  most_recent = true
  owners      = local.ami_owners
  image_id    = "ami-028daabcea4a77fb0"
}

data "aws_ami" "cptc-corp-kiosk03" {
  most_recent = true
  owners      = local.ami_owners
  image_id    = "ami-03c6ed7ccfc973cab"
}

data "aws_ami" "cptc-corp-kiosk04" {
  most_recent = true
  owners      = local.ami_owners
  image_id    = "ami-003c78bb7e40a15c1"
}
