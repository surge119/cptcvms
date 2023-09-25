module "network" {
  source = "./modules/network"
  name   = local.name

  vpc_cidr = local.vpc_cidr
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

module "corporate_instances" {
  source = "./modules/instances"

  name      = "${local.name}-corporate"
  vpc_id    = module.network.vpc_id
  key_name  = aws_key_pair.key_pair.key_name
  instances = local.corporate_instances
}

module "guest_instances" {
  source = "./modules/instances"

  name      = "${local.name}-guest"
  vpc_id    = module.network.vpc_id
  key_name  = aws_key_pair.key_pair.key_name
  instances = local.guest_instances
}

module "vpn_instances" {
  source = "./modules/instances"

  name     = local.name
  vpc_id   = module.network.vpc_id
  key_name = aws_key_pair.key_pair.key_name
  instances = [
    {
      name          = "wireguard_vpn"
      ami           = "ami-0a0c8eebcdd6dcbd0" // Ubuntu arm
      instance_type = "t4g.nano"
      subnet_id     = module.network.vpn_subnet_id
      private_ip    = "10.0.50.50"
      public_ip     = true
      ports = [
        {
          port        = -1
          protocol    = "icmp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          port        = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          port        = 51820
          protocol    = "udp"
          cidr_blocks = ["0.0.0.0/0"]
        },
      ]
    }
  ]
}

resource "local_file" "tf_ansible_vars" {
  content = <<-DOC
    tf_vpn_server_ip: ${module.vpn_instances.instances[0].ip}
    DOC

  filename = "./tf_ansible_vars.yml"
}

resource "local_file" "tf_ansible_inventory" {
  content = <<-DOC
    [vpn]
    ${module.vpn_instances.instances[0].ip}
    DOC

  filename = "../ansible/vpn/inventory.ini"
}
