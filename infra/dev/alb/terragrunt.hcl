include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/infra/modules/alb"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id         = "vpc-00000000000000000"
    vpc_cidr_block = "10.0.0.0/16"
    public_subnets = ["subnet-00000000000000001", "subnet-00000000000000002"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  vpc_id                     = dependency.vpc.outputs.vpc_id
  vpc_cidr_block             = dependency.vpc.outputs.vpc_cidr_block
  public_subnets             = dependency.vpc.outputs.public_subnets
  app_port                   = local.env.alb_app_port
  health_check_path          = local.env.alb_health_check_path
  certificate_arn            = local.env.alb_certificate_arn
  enable_deletion_protection = local.env.alb_enable_deletion_protection
  tags                       = local.env.tags
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}
