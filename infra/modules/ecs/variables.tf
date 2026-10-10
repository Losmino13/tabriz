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

variable "service_name" {
  description = "Short service name; the ECS service is <project>-<env>-<service_name>."
  type        = string
  default     = "web"
}

variable "container_name" {
  description = "Container name; must match tasks/task-definition.json in the app repo."
  type        = string
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 80
}

variable "bootstrap_image" {
  description = "Placeholder image for the first task definition; CI/CD replaces it on deploy."
  type        = string
  default     = "public.ecr.aws/nginx/nginx:stable-alpine"
}

variable "cpu" {
  description = "Task CPU units."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Task memory (MiB)."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of running tasks."
  type        = number
  default     = 1
}

variable "enable_execute_command" {
  description = "Enable ECS Exec on the service."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC of the service."
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs for the tasks."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB security group allowed to reach the container port."
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group the service registers into."
  type        = string
}

variable "task_exec_iam_role_arn" {
  description = "ECS task execution role ARN."
  type        = string
}

variable "tasks_iam_role_arn" {
  description = "ECS task role ARN."
  type        = string
}

variable "redis_security_group_id" {
  description = "Security group of the Redis replication group; null skips the ingress rule."
  type        = string
  default     = null
}

variable "redis_port" {
  description = "Redis port."
  type        = number
  default     = 6379
}

variable "enable_autoscaling" {
  description = "Enable CPU-based step scaling of the ECS service."
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks when autoscaling."
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks when autoscaling."
  type        = number
  default     = 4
}

variable "autoscaling_cpu_high_threshold" {
  description = "Average CPU % at or above which a task is added."
  type        = number
  default     = 80
}

variable "autoscaling_cpu_low_threshold" {
  description = "Average CPU % at or below which a task is removed."
  type        = number
  default     = 10
}

# variable "autoscaling_memory_high_threshold" {
#   description = "Average memory % at or above which a task is added."
#   type        = number
#   default     = 80
# }
#
# variable "autoscaling_memory_low_threshold" {
#   description = "Average memory % at or below which a task is removed."
#   type        = number
#   default     = 10
# }

variable "autoscaling_scale_out_cooldown" {
  description = "Seconds to wait after a scale-out before scaling again."
  type        = number
  default     = 60
}

variable "autoscaling_scale_in_cooldown" {
  description = "Seconds to wait after a scale-in before scaling again."
  type        = number
  default     = 300
}
