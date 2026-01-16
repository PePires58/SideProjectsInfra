# VPC Resource
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    Name        = "sideprojects-vpc"
    Environment = var.environment
  }
}

# Locals for safe subnet-AZ mapping
locals {
  # Ensure we have enough AZs for public subnets
  public_subnet_count  = length(var.public_subnet_cidrs)
  private_subnet_count = length(var.private_subnet_cidrs)

  # Use modulo to cycle through available AZs if we have more subnets than AZs
  public_subnet_azs = [
    for i in range(local.public_subnet_count) :
    var.availability_zones[i % length(var.availability_zones)]
  ]

  private_subnet_azs = [
    for i in range(local.private_subnet_count) :
    var.availability_zones[i % length(var.availability_zones)]
  ]
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "sideprojects-igw"
    Environment = var.environment
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.public_subnet_azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "sideprojects-public-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Public"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.private_subnet_azs[count.index]

  tags = {
    Name        = "sideprojects-private-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Private"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "sideprojects-public-rt"
    Environment = var.environment
  }
}

# Public Route to Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Public Route Table Association
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "sideprojects-private-rt"
    Environment = var.environment
  }
}

# Private Route Table Association
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
