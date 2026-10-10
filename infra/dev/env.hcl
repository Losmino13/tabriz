locals {
  env = "dev"

  # VPC
  vpc_cidr           = "10.10.0.0/16"
  az_count           = 3
  single_nat_gateway = true
  private_subnets = [
    "10.10.1.0/24",
    "10.10.2.0/24",
    "10.10.3.0/24"
  ]
  public_subnets = [
    "10.10.44.0/24",
    "10.10.55.0/24",
    "10.10.66.0/24"
  ]

  # ECS
  container_insights  = false
  fargate_weight      = 1
  fargate_spot_weight = 3
  log_retention_days  = 7

  # ECR
  ecr_repositories         = ["web"]
  ecr_image_tag_mutability = "MUTABLE"
  ecr_force_delete         = true
  ecr_keep_image_count     = 10

  # IAM
  enable_ecs_exec = true

  # Secrets Manager (stored as tabriz/dev/<key>)
  secrets = {
    db = {
      description       = "Postgres credentials for tabriz dev. Managed by Terraform."
      username          = "tabriz_dev"
      generate_password = true
    }
  }
  secrets_recovery_window_in_days = 0

  # ALB
  alb_app_port                   = 80
  alb_health_check_path          = "/"
  alb_certificate_arn            = null # set an ACM cert ARN to enable HTTPS
  alb_enable_deletion_protection = false

  tags = {
    Environment = local.env
    Project     = "tabriz"
    ManagedBy   = "terragrunt"
    Region      = "eu-central-1"
    Repository  = "https://github.com/Losmino13/tabriz"
  }
}
