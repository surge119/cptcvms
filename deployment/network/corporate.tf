locals {
  corporate_vms = [
    {
      name = "adcs"
      ami  = data.aws_ami.cptc-corp-adcs.image_id
      id   = "10.0.0.6"
    },
    {
      name       = "dc01"
      ami        = data.aws_ami.cptc-corp-dc01.image_id
      id         = true
      private_ip = "10.0.0.5"
    },
    {
      name = "doapi"
      ami  = data.aws_ami.cptc-corp-doapi.image_id
      id   = "10.0.0.7"
    },
    {
      name = "hms"
      ami  = data.aws_ami.cptc-corp-hms.image_id
      id   = "10.0.0.11"
    },
    {
      name = "ldap"
      ami  = data.aws_ami.cptc-corp-ldap.image_id
      id   = "10.0.0.100"
    },
    {
      name = "lps"
      ami  = data.aws_ami.cptc-corp-lps.image_id
      id   = "10.0.0.12"
    },
    {
      name = "media"
      ami  = data.aws_ami.cptc-corp-media.image_id
      id   = "10.0.0.20"
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
      name = "profiler"
      ami  = data.aws_ami.cptc-corp-profiler.image_id
      id   = "10.0.0.102"
    },
    {
      name = "workstation01"
      ami  = data.aws_ami.cptc-corp-workstation01.image_id
      id   = "10.0.0.51"
    },
    {
      name = "workstation02"
      ami  = data.aws_ami.cptc-corp-workstation02.image_id
      id   = "10.0.0.52"
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
  image_id    = "ami-0afd33cfe9c8e0d66"
}

data "aws_ami" "cptc-corp-dc01" {
  most_recent = true
  owners      = local.ami_owners
  image_id    = "ami-07b4273f227541bff"
}

data "aws_ami" "cptc-corp-doapi" {
  most_recent = true
  owners      = local.ami_owners
  image_id    = "ami-048984f8389164a46"
}

data "aws_ami" "cptc-corp-hms" {
  most_recent = true
  owners      = local.ami_owners
  image_id    = "ami-0647b402e25fb70f8"
}

data "aws_ami" "cptc-corp-ldap" {
  most_recent = true
  owners      = local.ami_owners
  image_id    = "ami-0c19ed51243876940"
}

data "aws_ami" "cptc-corp-lps" {
  most_recent = true
  owners      = local.ami_owners
  image_id    = "ami-0eedc80277d2ebed7"
}

data "aws_ami" "cptc-corp-media" {
  most_recent = true
  owners      = local.ami_owners
  image_id    = "ami-0b82130d627462610"
}

data "aws_ami" "cptc-corp-payment-db" {
  most_recent = true
  owners      = local.ami_owners
  image_id    = "ami-066f4ab32f25eb25a"
}

data "aws_ami" "cptc-corp-payment-web" {
  most_recent = true
  owners      = local.ami_owners
  image_id    = "ami-0abd54cb19c657249"
}

data "aws_ami" "cptc-corp-profiler" {
  most_recent = true
  owners      = local.ami_owners
  image_id    = "ami-0d6ca849652e4ebf3"
}

data "aws_ami" "cptc-corp-workstation01" {
  most_recent = true
  owners      = local.ami_owners
  image_id    = "ami-09efdff5e7caf7139"
}

data "aws_ami" "cptc-corp-workstation02" {
  most_recent = true
  owners      = local.ami_owners
  image_id    = "ami-026d4e538685ce775"
}
