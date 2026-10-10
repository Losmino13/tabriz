include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/infra/modules/github-oidc"
}

inputs = {
  tags = local.env.tags
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}
