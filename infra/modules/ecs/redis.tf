resource "aws_vpc_security_group_ingress_rule" "redis_from_service" {
  count = var.redis_security_group_id != null ? 1 : 0

  security_group_id            = var.redis_security_group_id
  referenced_security_group_id = aws_security_group.service.id
  description                  = "Redis from ${local.service_name}"
  ip_protocol                  = "tcp"
  from_port                    = var.redis_port
  to_port                      = var.redis_port

  tags = local.tags
}
