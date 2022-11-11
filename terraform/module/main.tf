resource "aws_vpc" "main" {
  cidr_block                       = var.cidr_block_vpc
  instance_tenancy                 = var.instance_tenancy
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    {"Name" = var.name },
    var.tags,
  ) 
}

# Public Subnet with Default Route to Internet Gateway
resource "aws_subnet" "public" {
  count = length(var.public_subnets) 

  vpc_id                          = aws_vpc.main.id
  cidr_block                      = element(concat(var.public_subnets, [""]), count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  assign_ipv6_address_on_creation = var.public_subnet_assign_ipv6_address_on_creation == null ? var.assign_ipv6_address_on_creation : var.public_subnet_assign_ipv6_address_on_creation
  ipv6_cidr_block                 = var.enable_ipv6 && length(var.public_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, var.public_subnet_ipv6_prefixes[count.index]) : null
  
  tags = merge(
    {
      "Name" = format(
        "${var.name}-public-subnet-%s",
        element(var.azs, count.index),
      )
    },
    var.tags,
  )
}

# Private Subnet with Default Route to NAT Gateway
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id                          = aws_vpc.main.id
  cidr_block                      = var.private_subnets[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  assign_ipv6_address_on_creation = var.private_subnet_assign_ipv6_address_on_creation == null ? var.assign_ipv6_address_on_creation : var.private_subnet_assign_ipv6_address_on_creation
  ipv6_cidr_block                 = var.enable_ipv6 && length(var.private_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, var.private_subnet_ipv6_prefixes[count.index]) : null
  
  tags = merge(
    {
      "Name" = format(
        "${var.name}-private-subnet-%s",
        element(var.azs, count.index),
      )
    },
    var.tags,
  )
}

# Main Internal Gateway for VPC
resource "aws_internet_gateway" "igw" {
  #count = var.create_igw && length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(
    { "Name" = "${var.name}-nat" },
    var.tags,
  )
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  
  tags = merge(
    { "Name" = var.name },
    var.tags,
  )

}

# Main NAT Gateway for VPC
resource "aws_nat_gateway" "nat" {

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    {"Name" = "Main NAT Gateway ${var.name}"},
    var.tags,
  )
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    { "Name" = "Public Route Table ${var.name}"},
    var.tags,
  )
}

# Association between Public Subnet and Public Route Table
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(
    { "Name" = "Private Route Table ${var.name}"},
    var.tags,
  )
}

# Association between Private Subnet and Private Route Table
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id 
  route_table_id = aws_route_table.private.id
}