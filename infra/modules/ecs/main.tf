module "cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 7.6"

  name = local.name

  setting = [
    {
      name  = "containerInsights"
      value = var.container_insights ? "enabled" : "disabled"
    }
  ]

  cluster_capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy = {
    FARGATE = {
      base   = 1
      weight = var.fargate_weight
    }
    FARGATE_SPOT = {
      weight = var.fargate_spot_weight
    }
  }

  cloudwatch_log_group_retention_in_days = var.log_retention_days

  tags = local.tags
}
