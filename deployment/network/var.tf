locals {
  name     = "cptc8"
  vpc_cidr = "10.0.0.0/16"
  subnets = {
    corporate = "10.0.0.0/24",
    guest     = "10.0.200.0/24",
    blue      = "10.0.100.0/24",
    red       = "10.0.150.0/24",
    infra     = "10.0.69.0/24"
  }
  # Note: Windows RDP is very unstable when this is false
  prod           = true
  cptc8_instance = local.prod ? "c6i.large" : "t3a.medium"
  ami_owners     = ["210706877716", "amazon"]
}
