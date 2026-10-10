variable "project" {
  description = "Project name, used as a name prefix."
  type        = string
}

variable "env" {
  description = "Environment name (dev, prod)."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks."
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks."
  type        = list(string)
}
variable "database_subnets" {
  description = "List of database subnet CIDR blocks."
  type        = list(string)
}
variable "az_count" {
  description = "Number of availability zones to spread subnets across."
  type        = number
  default     = 1
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway instead of one per AZ."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for all resources."
  type        = map(string)
  default     = {}
}
