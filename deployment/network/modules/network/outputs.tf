output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "corporate_subnet_id" {
  value = aws_subnet.subnets["corporate"].id
}

output "guest_subnet_id" {
  value = aws_subnet.subnets["guest"].id
}

output "vpn_subnet_id" {
  value = aws_subnet.subnets["vpn"].id
}

output "blue_subnet_id" {
  value = aws_subnet.subnets["blue"].id
}

output "red_subnet_id" {
  value = aws_subnet.subnets["red"].id
}

output "infra_subnet_id" {
  value = aws_subnet.subnets["infra"].id
}
