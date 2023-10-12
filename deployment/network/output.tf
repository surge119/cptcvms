output "vpn_ip" {
  value = aws_instance.vpn_instance.public_ip
}

output "infra_info" {
  value = module.infra_instances.instances
}
