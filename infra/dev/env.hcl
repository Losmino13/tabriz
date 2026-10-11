locals {
  env = "dev"

  vpc_cidr           = "10.10.0.0/16"
  az_count           = 2
  single_nat_gateway = true
  private_subnets = [
    "10.10.1.0/24",
    "10.10.4.0/24"
  ]

  public_subnets = [
    "10.10.2.0/24",
    "10.10.5.0/24"
  ]

  database_subnets = [
    "10.10.3.0/24",
    "10.10.6.0/24"
  ]

  container_insights  = false
  fargate_weight      = 1
  fargate_spot_weight = 3
  log_retention_days  = 7

  app_container_name = "tabriz"
  app_cpu            = 256
  app_memory         = 512
  app_desired_count  = 1

  ecr_repositories = [
    "web"
  ]

  ecr_image_tag_mutability = "MUTABLE"
  ecr_force_delete         = true
  ecr_keep_image_count     = 10

  github_repository = "Losmino13/tabriz"
  enable_ecs_exec   = true

  secrets = {
    db = {
      description       = "Postgres credentials for tabriz dev. Managed by Terraform."
      username          = "tabriz_dev"
      generate_password = true
    }
    redis = {
      description       = "Redis connection for tabriz dev. Managed by Terraform."
      generate_password = true
      password_key      = "auth_token"
      password_length   = 64
      password_special  = "!&#$^<>-"
      values = {
        host = "master.tabriz-dev-redis.xxxxxx.euc1.cache.amazonaws.com"
        port = "6379"
        tls  = "true"
      }
    }
  }

  secrets_recovery_window_in_days = 0

  redis_port = 6379

  alb_app_port                   = 80
  alb_health_check_path          = "/"
  alb_certificate_arn            = null
  alb_enable_deletion_protection = false

  tags = {
    Environment = local.env
    Project     = "tabriz"
    ManagedBy   = "terragrunt"
    Region      = "eu-central-1"
    Repository  = "https://github.com/Losmino13/tabriz"
  }
}
