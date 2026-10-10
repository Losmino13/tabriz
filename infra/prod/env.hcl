locals {
  env = "prod"

  # VPC
  vpc_cidr           = "10.20.0.0/16"
  az_count           = 3
  single_nat_gateway = false
  private_subnets = [
    "10.20.1.0/24",
    "10.20.2.0/24",
    "10.20.3.0/24"
  ]
  public_subnets = [
    "10.20.44.0/24",
    "10.20.55.0/24",
    "10.20.66.0/24"
  ]

  # ECS
  container_insights  = true
  fargate_weight      = 1
  fargate_spot_weight = 0
  log_retention_days  = 30

  # ECR
  ecr_repositories         = ["web"]
  ecr_image_tag_mutability = "IMMUTABLE"
  ecr_force_delete         = false
  ecr_keep_image_count     = 30

  # IAM
  enable_ecs_exec = false

  # Secrets Manager (stored as tabriz/prod/<key>)
  secrets = {
    db = {
      description       = "Postgres credentials for tabriz prod. Managed by Terraform."
      username          = "tabriz_prod"
      generate_password = true
    }
  }
  secrets_recovery_window_in_days = 30

  # ALB
  alb_app_port                   = 80
  alb_health_check_path          = "/"
  alb_certificate_arn            = null # set an ACM cert ARN to enable HTTPS
  alb_enable_deletion_protection = true

  tags = {
    Environment = local.env
    Project     = "tabriz"
    ManagedBy   = "terragrunt"
    Region      = "eu-central-1"
    Repository  = "https://github.com/Losmino13/tabriz"
  }
}
