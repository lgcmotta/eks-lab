data "aws_availability_zones" "available" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc.cidr_block
  tags = {
    Name = var.vpc.name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = var.vpc.internet_gateway
  }
  depends_on = [aws_vpc.this]
}

resource "aws_subnet" "public" {
  for_each                = { for idx, az in local.azs : az => idx }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc.cidr_block, 6, each.value)
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = merge(var.vpc.public_subnet_tags, {
    Name   = "${var.vpc.name}-public-${each.key}"
    Access = "public"
  })
  depends_on = [aws_vpc.this]
}

resource "aws_subnet" "private" {
  for_each                = { for idx, az in local.azs : az => idx }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc.cidr_block, 4, each.value + 4)
  availability_zone       = each.key
  map_public_ip_on_launch = false
  tags = merge(var.vpc.private_subnet_tags, {
    Name   = "${var.vpc.name}-private-${each.key}"
    Access = "private"
  })
  depends_on = [aws_vpc.this]
}

resource "aws_eip" "this" {
  for_each = aws_subnet.public
  tags = {
    Name = "${var.vpc.name}-eip-${each.key}"
  }
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  for_each      = aws_eip.this
  allocation_id = each.value.id
  subnet_id     = aws_subnet.public[each.key].id

  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = "${var.vpc.name}-nat-${each.key}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.vpc.name}-public-rt"
  }
  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
  depends_on     = [aws_route_table.public, aws_subnet.public]
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[each.key].id
  }

  tags = {
    Name = "${var.vpc.name}-private-rt-${each.key}"
  }
  depends_on = [aws_nat_gateway.this]
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
  depends_on     = [aws_route_table.private, aws_subnet.private]
}
