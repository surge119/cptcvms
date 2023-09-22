module "network" {
  source = "./modules/network"
  name   = local.name

  subnets = {
    corporate = "10.0.0.0/24",
    guest     = "10.0.200.0/24",
    vpn       = "10.0.50.0/24",
    blue      = "10.0.100.0/24",
    red       = "10.0.150.0/24",
    infra     = "10.0.69.0/24"
  }
}

resource "tls_private_key" "public_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.public_key.private_key_openssh
  filename        = "${path.module}/key.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "cptcvms-key"
  public_key = tls_private_key.public_key.public_key_openssh
}

module "instances" {
  source = "./modules/instances"

  name     = local.name
  vpc_id   = module.network.vpc_id
  key_name = aws_key_pair.key_pair.key_name
  instances = [{
    ami        = "ami-053b0d53c279acc90"
    name       = "vpn"
    subnet_id  = module.network.vpn_subnet_id
    private_ip = "10.0.50.50"
    ports      = [22, 51820]
    public_ip  = true
    },
    {
      ami  = "ami-012d19aacb8838ff6"
      name = ""
  }]
}

