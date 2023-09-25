output "vpn_info" {
  value = module.vpn_instances.instances
}

output "dns_ip" {
  value = module.infra_instances.instances
}
