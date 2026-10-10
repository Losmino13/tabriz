include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/infra/modules/ecr"
}

inputs = {
  repositories         = local.env.ecr_repositories
  image_tag_mutability = local.env.ecr_image_tag_mutability
  force_delete         = local.env.ecr_force_delete
  keep_image_count     = local.env.ecr_keep_image_count
  tags                 = local.env.tags
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}
