locals {
  name       = "${var.project}-${var.env}"
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region

  log_group_arn = "arn:aws:logs:${local.region}:${local.account_id}:log-group:/ecs/${local.name}*"

  roles = {
    ecs_task_execution = {
      name                    = "${local.name}-ecs-task-execution"
      description             = "ECS task execution role for ${local.name}: ECR pull, CloudWatch Logs, Secrets Manager"
      create_inline_policy    = true
      inline_policy_documents = [data.aws_iam_policy_document.ecs_task_execution.json]
    }
    ecs_task = {
      name                    = "${local.name}-ecs-task"
      description             = "ECS task role for ${local.name}: application access to AWS services"
      create_inline_policy    = var.enable_ecs_exec
      inline_policy_documents = var.enable_ecs_exec ? [data.aws_iam_policy_document.ecs_task.json] : []
    }
  }
}
