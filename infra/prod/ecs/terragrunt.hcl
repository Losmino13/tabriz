include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/infra/modules/ecs"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id                  = "vpc-00000000000000000"
    private_subnets         = ["subnet-00000000000000001", "subnet-00000000000000002"]
    redis_security_group_id = "sg-00000000000000001"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "alb" {
  config_path = "../alb"

  mock_outputs = {
    alb_security_group_id = "sg-00000000000000000"
    target_group_arn      = "arn:aws:elasticloadbalancing:eu-central-1:000000000000:targetgroup/mock/0000000000000000"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "iam" {
  config_path = "../iam"

  mock_outputs = {
    ecs_task_execution_role_arn = "arn:aws:iam::000000000000:role/mock-exec"
    ecs_task_role_arn           = "arn:aws:iam::000000000000:role/mock-task"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

# Ordering only: images and secrets must exist before tasks start.
dependencies {
  paths = ["../ecr", "../secretsmanager"]
}

inputs = {
  container_insights  = local.env.container_insights
  fargate_weight      = local.env.fargate_weight
  fargate_spot_weight = local.env.fargate_spot_weight
  log_retention_days  = local.env.log_retention_days

  container_name         = local.env.app_container_name
  container_port         = local.env.alb_app_port
  cpu                    = local.env.app_cpu
  memory                 = local.env.app_memory
  desired_count          = local.env.app_desired_count
  enable_execute_command = local.env.enable_ecs_exec

  enable_autoscaling             = local.env.enable_autoscaling
  autoscaling_min_capacity       = local.env.autoscaling_min_capacity
  autoscaling_max_capacity       = local.env.autoscaling_max_capacity
  autoscaling_cpu_high_threshold = local.env.autoscaling_cpu_high_threshold
  autoscaling_cpu_low_threshold  = local.env.autoscaling_cpu_low_threshold

  vpc_id                 = dependency.vpc.outputs.vpc_id
  private_subnets        = dependency.vpc.outputs.private_subnets
  alb_security_group_id  = dependency.alb.outputs.alb_security_group_id
  target_group_arn       = dependency.alb.outputs.target_group_arn
  task_exec_iam_role_arn = dependency.iam.outputs.ecs_task_execution_role_arn
  tasks_iam_role_arn     = dependency.iam.outputs.ecs_task_role_arn

  redis_security_group_id = dependency.vpc.outputs.redis_security_group_id
  redis_port              = local.env.redis_port

  tags = local.env.tags
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}
