variable "project" {
  description = "Project name, used as a name prefix."
  type        = string
}

variable "env" {
  description = "Environment name (dev, prod)."
  type        = string
}

variable "ecr_repository_arns" {
  description = "ECR repository ARNs the task execution role may pull from."
  type        = list(string)
}

variable "secret_arns" {
  description = "Secrets Manager secret ARNs the task execution role may read."
  type        = list(string)
  default     = []
}

variable "enable_ecs_exec" {
  description = "Allow ECS Exec (SSM Session Manager) into running tasks."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for all resources."
  type        = map(string)
  default     = {}
}

variable "github_repository" {
  description = "GitHub repository (owner/name) allowed to deploy via OIDC."
  type        = string
}

variable "github_environment" {
  description = "GitHub environment the deploy job must run in; defaults to env."
  type        = string
  default     = null
}
