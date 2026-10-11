module "service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 7.6"

  name        = local.service_name
  cluster_arn = module.cluster.arn

  family = local.service_name
  cpu    = var.cpu
  memory = var.memory

  runtime_platform = {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = {
    (var.container_name) = {
      image                  = var.bootstrap_image
      essential              = true
      readonlyRootFilesystem = false

      portMappings = [
        {
          name          = var.container_name
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      enable_cloudwatch_logging              = true
      cloudwatch_log_group_name              = "/ecs/${local.service_name}"
      cloudwatch_log_group_retention_in_days = var.log_retention_days
    }
  }

  ignore_task_definition_changes = true
  track_latest                   = false
  skip_destroy                   = true

  desired_count                     = var.desired_count
  enable_autoscaling                = false
  health_check_grace_period_seconds = 60
  enable_execute_command            = var.enable_execute_command

  capacity_provider_strategy = {
    FARGATE = {
      capacity_provider = "FARGATE"
      base              = 1
      weight            = var.fargate_weight
    }
    FARGATE_SPOT = {
      capacity_provider = "FARGATE_SPOT"
      weight            = var.fargate_spot_weight
    }
  }

  load_balancer = {
    service = {
      container_name   = var.container_name
      container_port   = var.container_port
      target_group_arn = var.target_group_arn
    }
  }

  subnet_ids       = var.private_subnets
  assign_public_ip = false

  create_security_group = false
  security_group_ids    = [aws_security_group.service.id]

  create_task_exec_iam_role = false
  task_exec_iam_role_arn    = var.task_exec_iam_role_arn

  create_tasks_iam_role = false
  tasks_iam_role_arn    = var.tasks_iam_role_arn

  tags = local.tags
}
