module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6"

  name = local.name
  cidr = var.vpc_cidr
  azs  = local.azs


  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.tags
}
