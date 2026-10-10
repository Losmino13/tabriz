output "provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider."
  value       = module.github_oidc_provider.arn
}
