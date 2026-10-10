variable "project" {
  description = "Project name, used as a name prefix."
  type        = string
}

variable "env" {
  description = "Environment name (dev, prod)."
  type        = string
}

variable "container_insights" {
  description = "Enable CloudWatch Container Insights."
  type        = bool
  default     = false
}

variable "fargate_weight" {
  description = "Default capacity provider strategy weight for FARGATE."
  type        = number
  default     = 1
}

variable "fargate_spot_weight" {
  description = "Default capacity provider strategy weight for FARGATE_SPOT."
  type        = number
  default     = 0
}

variable "log_retention_days" {
  description = "Retention for the cluster CloudWatch log group."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags for all resources."
  type        = map(string)
  default     = {}
}
