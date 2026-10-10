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
