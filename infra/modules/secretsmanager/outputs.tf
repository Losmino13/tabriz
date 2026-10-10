output "secret_arns" {
  description = "Map of secret key to secret ARN."
  value       = { for k, m in module.secrets_manager : k => m.secret_arn }
}

output "secret_names" {
  description = "Map of secret key to secret name."
  value       = { for k, m in module.secrets_manager : k => m.secret_name }
}
