# Security group for the Redis (ElastiCache) replication group.
# Attach it to the replication group; ingress from the ECS service is added in modules/ecs.
module "redis_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0"

  name            = "${local.name}-redis"
  description     = "Redis (ElastiCache) - ingress only from app security groups"
  vpc_id          = module.vpc.vpc_id
  use_name_prefix = false

  tags = var.tags
}
