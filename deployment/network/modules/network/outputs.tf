output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "lab_subnet" {
  value = aws_subnet.subnets["lab"]
}

output "blue_subnet" {
  value = aws_subnet.subnets["blue"]
}

output "red_subnet" {
  value = aws_subnet.subnets["red"]
}

output "vpn_subnet" {
  value = aws_subnet.subnets["vpn"]
}