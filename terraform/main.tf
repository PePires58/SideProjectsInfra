module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "sideprojects-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = merge(
    var.common_tags
  )

  public_subnet_tags = {
    Type = "Public"
  }

  private_subnet_tags = {
    Type = "Private"
  }
}

module "public_app_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "public-app-sg"
  description = "Security group for public application servers"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["http-80-tcp","https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Public application ports"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}