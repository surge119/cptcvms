locals {
  name           = "cptc8"
  vpc_cidr       = "10.0.0.0/16"
  prod           = true
  cptc8_instance = local.prod ? "c6i.large" : "t3a.medium"
  ami_owners     = ["210706877716"]
}
