output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  description = "IDs of the public subnets."
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "IDs of the private subnets."
  value       = module.vpc.private_subnets
}

output "azs" {
  description = "Availability zones used."
  value       = local.azs
}

output "database_subnets" {
  description = "IDs of the database subnets (place the Redis replication group here)."
  value       = module.vpc.database_subnets
}

output "redis_security_group_id" {
  description = "Security group to attach to the Redis replication group."
  value       = module.redis_sg.id
}
