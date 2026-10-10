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
