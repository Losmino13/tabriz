locals {
  env = "prod"

  vpc_cidr           = "10.20.0.0/16"
  az_count           = 2
  single_nat_gateway = true
  private_subnets = [
    "10.20.11.0/24",
    "10.20.22.0/24"
  ]
  public_subnets = [
    "10.20.33.0/24",
    "10.20.44.0/24"
  ]
  database_subnets = [
    "10.20.55.0/24",
    "10.20.66.0/24"
  ]
  container_insights  = true
  fargate_weight      = 1
  fargate_spot_weight = 0
  log_retention_days  = 30

  app_container_name = "tabriz"
  app_cpu            = 256
  app_memory         = 512
  app_desired_count  = 2

  enable_autoscaling             = true
  autoscaling_min_capacity       = 2
  autoscaling_max_capacity       = 6
  autoscaling_cpu_high_threshold = 80
  autoscaling_cpu_low_threshold  = 10

  ecr_repositories         = ["web"]
  ecr_image_tag_mutability = "IMMUTABLE"
  ecr_force_delete         = false
  ecr_keep_image_count     = 30

  github_repository = "Losmino13/tabriz"
  enable_ecs_exec   = false

  secrets = {
    db = {
      description       = "Postgres credentials for tabriz prod. Managed by Terraform."
      username          = "tabriz_prod"
      generate_password = true
    }
    redis = {
      description       = "Redis connection for tabriz prod. Managed by Terraform."
      generate_password = true
      password_key      = "auth_token"
      password_length   = 64
      password_special  = "!&#$^<>-"
      values = {
        host = "master.tabriz-prod-redis.xxxxxx.euc1.cache.amazonaws.com"
        port = "6379"
        tls  = "true"
      }
    }
  }
  secrets_recovery_window_in_days = 30

  redis_port = 6379

  alb_app_port                   = 80
  alb_health_check_path          = "/"
  alb_certificate_arn            = null
  alb_enable_deletion_protection = true

  tags = {
    Environment = local.env
    Project     = "tabriz"
    ManagedBy   = "terragrunt"
    Region      = "eu-central-1"
    Repository  = "https://github.com/Losmino13/tabriz"
  }
}
