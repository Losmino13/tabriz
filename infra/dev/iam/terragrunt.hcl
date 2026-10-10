include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/infra/modules/iam"
}

dependency "ecr" {
  config_path = "../ecr"

  mock_outputs = {
    repository_arns = { web = "arn:aws:ecr:eu-central-1:000000000000:repository/mock" }
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "secretsmanager" {
  config_path = "../secretsmanager"

  mock_outputs = {
    secret_arns = { db = "arn:aws:secretsmanager:eu-central-1:000000000000:secret:mock" }
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  ecr_repository_arns = values(dependency.ecr.outputs.repository_arns)
  secret_arns         = values(dependency.secretsmanager.outputs.secret_arns)
  enable_ecs_exec     = local.env.enable_ecs_exec
  github_repository   = local.env.github_repository
  tags                = local.env.tags
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

# GitHub deploy role trusts the account-wide OIDC provider.
dependencies {
  paths = ["../../global/github-oidc"]
}
