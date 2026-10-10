output "alb_arn" {
  description = "ARN of the ALB."
  value       = module.alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB."
  value       = module.alb.dns_name
}

output "alb_zone_id" {
  description = "Route 53 zone ID of the ALB (for alias records)."
  value       = module.alb.zone_id
}

output "alb_security_group_id" {
  description = "ALB security group ID; allow it as ingress source on the ECS service."
  value       = module.alb.security_group_id
}

output "target_group_arn" {
  description = "ARN of the app target group; use in the ECS service load_balancer block."
  value       = module.alb.target_groups["app"].arn
}
