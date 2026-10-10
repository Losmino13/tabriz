include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/infra/modules/ecs"
}

inputs = {
  container_insights  = local.env.container_insights
  fargate_weight      = local.env.fargate_weight
  fargate_spot_weight = local.env.fargate_spot_weight
  log_retention_days  = local.env.log_retention_days
  tags                = local.env.tags
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

# A Fargate cluster needs no VPC inputs; services added later will.
dependencies {
  paths = ["../vpc", "../ecr", "../iam", "../secretsmanager", "../alb"]
}
