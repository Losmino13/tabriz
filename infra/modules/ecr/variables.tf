variable "project" {
  description = "Project name, used as a name prefix."
  type        = string
}

variable "env" {
  description = "Environment name (dev, prod)."
  type        = string
}

variable "repositories" {
  description = "Repository names to create, prefixed with <project>-<env>/."
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "MUTABLE or IMMUTABLE image tags."
  type        = string
  default     = "IMMUTABLE"
}

variable "force_delete" {
  description = "Delete repositories even if they contain images."
  type        = bool
  default     = false
}

variable "keep_image_count" {
  description = "Number of most recent images to keep; older ones are expired."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags for all resources."
  type        = map(string)
  default     = {}
}
