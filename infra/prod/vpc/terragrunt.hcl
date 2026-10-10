include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/infra/modules/vpc"
}

inputs = {
  vpc_cidr           = local.env.vpc_cidr
  az_count           = local.env.az_count
  single_nat_gateway = local.env.single_nat_gateway
  private_subnets    = local.env.private_subnets
  public_subnets     = local.env.public_subnets
  database_subnets   = local.env.database_subnets
  tags               = local.env.tags
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}
