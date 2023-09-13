module "network" {
  source = "./modules/network"
  name   = local.name

}

resource "tls_private_key" "public_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.public_key.private_key_openssh
  filename = "${path.module}/key.pem"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "cptcvms-key"
  public_key = tls_private_key.public_key.public_key_openssh
}

module "instances" {
  source = "./modules/instances"
  
  name   = local.name
  vpc_id = module.network.vpc_id
  key_name = aws_key_pair.key_pair.key_name
  instances = [{
    name       = "vpn"
    subnet_id  = module.network.vpn_subnet.id
    private_ip = "10.0.50.50"
    ports      = [22, 51820]
    public_ip  = true
  }]
}

