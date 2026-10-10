include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/infra/modules/secretsmanager"
}

inputs = {
  secrets                 = local.env.secrets
  recovery_window_in_days = local.env.secrets_recovery_window_in_days
  tags                    = local.env.tags
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}
