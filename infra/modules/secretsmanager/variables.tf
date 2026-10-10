variable "project" {
  description = "Project name, used as a name prefix."
  type        = string
}

variable "env" {
  description = "Environment name (dev, prod)."
  type        = string
}

variable "secrets" {
  description = "Secrets to create, keyed by short name. Stored as <project>/<env>/<key>."
  type = map(object({
    description       = string
    username          = optional(string)
    generate_password = optional(bool, false)
    password_length   = optional(number, 32)
  }))
  default = {}
}

variable "recovery_window_in_days" {
  description = "Days AWS keeps a deleted secret before removing it (0 deletes immediately)."
  type        = number
  default     = 30
}

variable "secret_version" {
  description = "Increment to regenerate and rewrite secret values."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Additional tags for all resources."
  type        = map(string)
  default     = {}
}
