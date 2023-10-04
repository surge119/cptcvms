resource "aws_vpc" "vpc" {
  cidr_block = local.vpc_cidr

  enable_dns_hostnames = true

  tags = {
    Name = "${local.name}-vpc"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.name}-internet_gateway"
  }
}

resource "aws_route_table" "default_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${local.name}-def_route_table"
  }
}

resource "aws_route_table" "wg_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${local.name}-wg_route_table"
  }
}

resource "aws_subnet" "subnets" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1a"

  for_each = local.subnets

  cidr_block = each.value

  tags = {
    Name = "${local.name}-${each.key}-subnet"
  }
}

resource "aws_route_table_association" "aws_route_table_association" {
  for_each = aws_subnet.subnets

  route_table_id = aws_route_table.default_route_table.id
  subnet_id      = each.value.id
}

resource "aws_route_table_association" "aws_route_table_association_vpn" {
  route_table_id = aws_route_table.wg_route_table.id
  subnet_id      = aws_subnet.vpn_subnets.id
}
