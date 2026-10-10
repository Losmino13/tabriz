module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10"

  name                       = local.name
  vpc_id                     = var.vpc_id
  subnets                    = var.public_subnets
  enable_deletion_protection = var.enable_deletion_protection

  security_group_ingress_rules = {
    for k, port in local.ingress_ports : k => {
      description = "${upper(k)} from ${var.ingress_cidr}"
      from_port   = port
      to_port     = port
      ip_protocol = "tcp"
      cidr_ipv4   = var.ingress_cidr
    }
  }

  security_group_egress_rules = {
    to_vpc = {
      description = "All outbound to ECS tasks in the VPC"
      ip_protocol = "-1"
      cidr_ipv4   = var.vpc_cidr_block
    }
  }

  # Without a certificate HTTP forwards to the app; with one it redirects to HTTPS.
  listeners = merge(
    {
      http = {
        port     = 80
        protocol = "HTTP"

        forward = local.https_enabled ? null : { target_group_key = "app" }
        redirect = local.https_enabled ? {
          port        = "443"
          protocol    = "HTTPS"
          status_code = "HTTP_301"
        } : null
      }
    },
    {
      for k, v in {
        https = {
          port            = 443
          protocol        = "HTTPS"
          certificate_arn = var.certificate_arn
          ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
          forward         = { target_group_key = "app" }
        }
      } : k => v if local.https_enabled
    }
  )

  target_groups = {
    app = {
      name              = "${local.name}-app"
      protocol          = "HTTP"
      port              = var.app_port
      target_type       = "ip"
      create_attachment = false

      health_check = {
        enabled             = true
        path                = var.health_check_path
        matcher             = "200"
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
      }

      deregistration_delay = 30
    }
  }

  tags = var.tags
}
