module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "sideprojects-vpc-${var.environment}"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )

  public_subnet_tags = {
    Type = "Public"
  }

  private_subnet_tags = {
    Type = "Private"
  }
}
