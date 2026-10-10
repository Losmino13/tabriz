output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role (task definition execution_role_arn)."
  value       = module.iam_role["ecs_task_execution"].arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role (task definition task_role_arn)."
  value       = module.iam_role["ecs_task"].arn
}

output "log_group_prefix" {
  description = "CloudWatch log group name prefix writable by the task execution role."
  value       = "/ecs/${local.name}"
}
