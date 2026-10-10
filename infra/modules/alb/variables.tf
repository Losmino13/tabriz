variable "project" {
  description = "Project name, used as a name prefix."
  type        = string
}

variable "env" {
  description = "Environment name (dev, prod)."
  type        = string
}

variable "vpc_id" {
  description = "VPC to place the ALB in."
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR, allowed as egress target (ECS tasks)."
  type        = string
}

variable "public_subnets" {
  description = "Public subnet IDs for the ALB."
  type        = list(string)
}

variable "app_port" {
  description = "Port the ECS service container listens on."
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Target group health check path."
  type        = string
  default     = "/"
}

variable "certificate_arn" {
  description = "ACM certificate ARN. When null, the ALB serves plain HTTP only."
  type        = string
  default     = null
}

variable "ingress_cidr" {
  description = "CIDR allowed to reach the ALB on 80/443."
  type        = string
  default     = "0.0.0.0/0"
}

variable "enable_deletion_protection" {
  description = "Protect the ALB from deletion."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for all resources."
  type        = map(string)
  default     = {}
}
