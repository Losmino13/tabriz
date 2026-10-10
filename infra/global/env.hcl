# Account-wide resources shared by dev and prod.
locals {
  env = "global"

  tags = {
    Environment = local.env
    Project     = "tabriz"
    ManagedBy   = "terragrunt"
    Region      = "eu-central-1"
    Repository  = "https://github.com/Losmino13/tabriz"
  }
}
