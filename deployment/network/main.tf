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
  vpc_id    = aws_vpc.vpc.id
  key_name  = aws_key_pair.key_pair.key_name
  instances = local.corporate_instances
}

module "guest_instances" {
  source = "./modules/instances"

  name      = "${local.name}-guest"
  vpc_id    = aws_vpc.vpc.id
  key_name  = aws_key_pair.key_pair.key_name
  instances = local.guest_instances
}

module "blue_instances" {
  source = "./modules/instances"

  name     = "${local.name}-blue"
  vpc_id   = aws_vpc.vpc.id
  key_name = aws_key_pair.key_pair.key_name
  instances = [
    {
      name          = "wazuh"
      ami           = "ami-053b0d53c279acc90" // Ubuntu x86
      instance_type = "t3a.medium"
      subnet_id     = aws_subnet.subnets["blue"].id
      private_ip    = "10.0.100.100"
      public_ip     = true
      volume_size   = 50
      ports = [
        {
          port        = 0
          protocol    = "-1"
          cidr_blocks = ["10.0.0.0/16"]
        },
      ]
    }
  ]
}

module "infra_instances" {
  source = "./modules/instances"

  name     = "${local.name}-infra"
  vpc_id   = aws_vpc.vpc.id
  key_name = aws_key_pair.key_pair.key_name
  instances = [
    {
      name          = "scorestack"
      ami           = "ami-053b0d53c279acc90" // Ubuntu x86
      instance_type = "t3a.medium"
      subnet_id     = aws_subnet.subnets["infra"].id
      private_ip    = "10.0.69.100"
      public_ip     = true
      volume_size   = 20
      ports = [
        {
          port        = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        },
      ]
    }
  ]
}

resource "local_file" "tf_ansible_scorestack_inventory" {
  content = <<-DOC
    [scorestack]
    ${module.infra_instances.instances[0].ip}
    DOC

  filename = "../ansible/scorestack/inventory.ini"
}

resource "local_file" "tf_ansible_vpn_vars" {
  content = <<-DOC
    tf_vpn_server_ip: ${aws_instance.vpn_instance.public_ip}
    DOC

  filename = "./tf_ansible_vars.yml"
}

resource "local_file" "tf_ansible_vpn_inventory" {
  content = <<-DOC
    [vpn]
    ${aws_instance.vpn_instance.public_ip}
    DOC

  filename = "../ansible/vpn/inventory.ini"
}
