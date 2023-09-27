output "vpn_info" {
  value = module.vpn_instances.instances
}

output "infra_info" {
  value = module.infra_instances.instances
}
