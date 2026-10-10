locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  project    = "tabriz"
  region     = "eu-central-1"
  env        = local.env_vars.locals.env
  account_id = get_aws_account_id()
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket       = "${local.project}-tfstate-${local.account_id}"
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = local.region
    encrypt      = true
    use_lockfile = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOT
    provider "aws" {
      region = "${local.region}"

      default_tags {
        tags = {
          Project     = "${local.project}"
          Environment = "${local.env}"
          ManagedBy   = "terragrunt"
        }
      }
    }
  EOT
}

inputs = {
  project = local.project
  env     = local.env
}
