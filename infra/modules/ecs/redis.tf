# Lets the ECS tasks (and only them) reach Redis: SG-to-SG reference, not a CIDR,
# so it follows task ENIs as Fargate replaces them.
resource "aws_vpc_security_group_ingress_rule" "redis_from_service" {
  count = var.redis_security_group_id != null ? 1 : 0

  security_group_id            = var.redis_security_group_id
  referenced_security_group_id = module.service.security_group_id
  description                  = "Redis from ${local.service_name}"
  ip_protocol                  = "tcp"
  from_port                    = var.redis_port
  to_port                      = var.redis_port

  tags = var.tags
}
