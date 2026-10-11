locals {
  name         = "${var.project}-${var.env}"
  service_name = "${local.name}-${var.service_name}"

  tags = merge(
    {
      Project     = var.project
      Environment = var.env
      ManagedBy   = "terragrunt"
    },
    var.tags,
  )
}
