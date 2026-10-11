resource "aws_security_group" "service" {
  name_prefix = "${local.service_name}-ecs-"
  description = "Security group for ECS Service ${local.service_name}"
  vpc_id      = var.vpc_id

  tags = merge(local.tags, { Name = "${local.service_name}-ecs" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.service.id
  referenced_security_group_id = var.alb_security_group_id
  description                  = "App port from ALB only"
  ip_protocol                  = "tcp"
  from_port                    = var.container_port
  to_port                      = var.container_port

  tags = merge(local.tags, { Name = "${local.service_name}-ecs-app_from_alb" })
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.service.id
  description       = "All outbound (ECR, Secrets Manager, CloudWatch via NAT)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(local.tags, { Name = "${local.service_name}-ecs-all_outbound" })
}
