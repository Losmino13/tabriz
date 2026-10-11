output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.cluster.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = module.cluster.arn
}

output "cluster_id" {
  description = "ID of the ECS cluster."
  value       = module.cluster.id
}

output "service_name" {
  description = "Name of the ECS service."
  value       = module.service.name
}

output "task_definition_family" {
  description = "Task definition family used by CI/CD."
  value       = module.service.task_definition_family
}

output "service_security_group_id" {
  description = "Security group of the ECS service tasks."
  value       = aws_security_group.service.id
}
