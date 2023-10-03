locals {
  corporate_vms = [
    {
      name       = "adcs"
      ami        = data.aws_ami.cptc-corp-adcs.image_id
      private_ip = "10.0.0.6"
    },
    {
      name       = "dc01"
      ami        = data.aws_ami.cptc-corp-dc01.image_id
      public_ip  = true
      private_ip = "10.0.0.5"
    },
    {
      name       = "doapi"
      ami        = data.aws_ami.cptc-corp-doapi.image_id
      private_ip = "10.0.0.7"
    },
    {
      name       = "hms"
      ami        = data.aws_ami.cptc-corp-hms.image_id
      private_ip = "10.0.0.11"
    },
    {
      name       = "ldap"
      ami        = data.aws_ami.cptc-corp-ldap.image_id
      private_ip = "10.0.0.100"
    },
    {
      name       = "lps"
      ami        = data.aws_ami.cptc-corp-lps.image_id
      private_ip = "10.0.0.12"
    },
    {
      name       = "media"
      ami        = data.aws_ami.cptc-corp-media.image_id
      private_ip = "10.0.0.20"
    },
    {
      name       = "payment-db"
      ami        = data.aws_ami.cptc-corp-payment-db.image_id
      private_ip = "10.0.0.210"
    },
    {
      name       = "payment-web"
      ami        = data.aws_ami.cptc-corp-payment-web.image_id
      private_ip = "10.0.0.200"
    },
    {
      name       = "profiler"
      ami        = data.aws_ami.cptc-corp-profiler.image_id
      private_ip = "10.0.0.102"
    },
    {
      name       = "workstation01"
      ami        = data.aws_ami.cptc-corp-workstation01.image_id
      private_ip = "10.0.0.51"
    },
    {
      name       = "workstation02"
      ami        = data.aws_ami.cptc-corp-workstation02.image_id
      private_ip = "10.0.0.52"
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
    name   = "tag:Name"
    values = ["cptc8-adcs"]
  }
}

data "aws_ami" "cptc-corp-dc01" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "tag:Name"
    values = ["cptc8-dc01"]
  }
}

data "aws_ami" "cptc-corp-doapi" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "tag:Name"
    values = ["cptc8-doapi"]
  }
}

data "aws_ami" "cptc-corp-hms" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "tag:Name"
    values = ["cptc8-hms"]
  }
}

data "aws_ami" "cptc-corp-ldap" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "tag:Name"
    values = ["cptc8-ldap"]
  }
}

data "aws_ami" "cptc-corp-lps" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "tag:Name"
    values = ["cptc8-lps"]
  }
}

data "aws_ami" "cptc-corp-media" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "tag:Name"
    values = ["cptc8-media"]
  }
}

data "aws_ami" "cptc-corp-payment-db" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "tag:Name"
    values = ["cptc8-payment-db"]
  }
}

data "aws_ami" "cptc-corp-payment-web" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "tag:Name"
    values = ["cptc8-payment-web"]
  }
}

data "aws_ami" "cptc-corp-profiler" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "tag:Name"
    values = ["cptc8-profiler"]
  }
}

data "aws_ami" "cptc-corp-workstation01" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "tag:Name"
    values = ["cptc8-workstation01"]
  }
}

data "aws_ami" "cptc-corp-workstation02" {
  most_recent = true
  owners      = local.ami_owners
  filter {
    name   = "tag:Name"
    values = ["cptc8-workstation02"]
  }
}
