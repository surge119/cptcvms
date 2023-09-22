resource "aws_instance" "instance" {
  key_name = var.key_name

  for_each = {
    for index, instance in var.instances :
    index => instance
  }

  subnet_id = each.value.subnet_id
}

# module "instance" {
#   source = "./ec2"

#   for_each = {
#     for index, instance in var.instances :
#     index => instance
#   }

#   name       = each.value.name
#   ami        = var.ami
#   vpc_id     = var.vpc_id
#   key_name   = var.key_name
#   subnet_id  = each.value.subnet_id
#   private_ip = each.value.private_ip
#   ports      = each.value.ports
#   public_ip  = each.value.public_ip
# }
