locals {
  corporate_vms = [
    {
      name       = "adcs"
      ami        = data.aws_ami.cptc-corp-adcs.id
      private_ip = "10.0.0.6"
    },
    {
      name       = "dc01"
      ami        = data.aws_ami.cptc-corp-dc01.id
      id         = true
      private_ip = "10.0.0.5"
    },
    {
      name       = "doapi"
      ami        = data.aws_ami.cptc-corp-doapi.id
      private_ip = "10.0.0.7"
    },
    {
      name       = "hms"
      ami        = data.aws_ami.cptc-corp-hms.id
      private_ip = "10.0.0.11"
    },
    {
      name       = "ldap"
      ami        = data.aws_ami.cptc-corp-ldap.id
      private_ip = "10.0.0.100"
    },
    {
      name       = "lps"
      ami        = data.aws_ami.cptc-corp-lps.id
      private_ip = "10.0.0.12"
    },
    {
      name       = "media"
      ami        = data.aws_ami.cptc-corp-media.id
      private_ip = "10.0.0.20"
    },
    {
      name       = "payment-db"
      ami        = data.aws_ami.cptc-corp-payment-db.id
      private_ip = "10.0.0.210"
    },
    {
      name       = "payment-web"
      ami        = data.aws_ami.cptc-corp-payment-web.id
      private_ip = "10.0.0.200"
    },
    {
      name       = "profiler"
      ami        = data.aws_ami.cptc-corp-profiler.id
      private_ip = "10.0.0.102"
    },
    {
      name       = "workstation01"
      ami        = data.aws_ami.cptc-corp-workstation01.id
      private_ip = "10.0.0.51"
    },
    {
      name       = "workstation02"
      ami        = data.aws_ami.cptc-corp-workstation02.id
      private_ip = "10.0.0.52"
    }
  ]
  corporate_instances = [
    for vm in local.corporate_vms :
    {
      name          = vm.name
      ami           = vm.ami
      instance_type = local.cptc8_instance
      subnet_id     = aws_subnet.subnets["corporate"].id
      private_ip    = vm.private_ip
      public_ip     = true
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

data "aws_ami" "cptc-corp-adcs" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "Name"
    values = ["import-ami-0cbfcc5f36f2cd85c"]
  }
}

data "aws_ami" "cptc-corp-dc01" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "Name"
    values = ["import-ami-00d057fec5a8e931f"]
  }
}

data "aws_ami" "cptc-corp-doapi" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "Name"
    values = ["import-ami-02c5eea4a49fdc04c"]
  }
}

data "aws_ami" "cptc-corp-hms" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "Name"
    values = ["import-ami-05d7d55c3c16543e6"]
  }
}

data "aws_ami" "cptc-corp-ldap" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "Name"
    values = ["import-ami-06293b32f70c0b7bb"]
  }
}

data "aws_ami" "cptc-corp-lps" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "Name"
    values = ["import-ami-0a9000656f5d014c3"]
  }
}

data "aws_ami" "cptc-corp-media" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "Name"
    values = ["import-ami-0570a4e7eee09a453"]
  }
}

data "aws_ami" "cptc-corp-payment-db" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "Name"
    values = ["import-ami-0a370690ea1daf062"]
  }
}

data "aws_ami" "cptc-corp-payment-web" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "Name"
    values = ["import-ami-02a533ae9f3cbb3e0"]
  }
}

data "aws_ami" "cptc-corp-profiler" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "Name"
    values = ["import-ami-01ab6d294c050ea95"]
  }
}

data "aws_ami" "cptc-corp-workstation01" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "Name"
    values = ["import-ami-0b00af9303f9caaf9"]
  }
}

data "aws_ami" "cptc-corp-workstation02" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "Name"
    values = ["import-ami-0f376f13e147c70e3"]
  }
}
