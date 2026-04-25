variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "AWS region for resources"
}

variable "environment" {
  type        = string
  default     = "production"
  description = "Environment name"
}

variable "project_name" {
  type        = string
  default     = "agri-platform"
  description = "Project name for tagging"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for VPC"
}

variable "app_name" {
  type        = string
  default     = "agri-platform"
  description = "Application name"
}

variable "app_port" {
  type        = number
  default     = 8000
  description = "Application port"
}

variable "container_image" {
  type        = string
  description = "Docker image URI for the application"
}

variable "container_cpu" {
  type        = number
  default     = 512
  description = "CPU units for ECS task (256, 512, 1024, etc.)"
}

variable "container_memory" {
  type        = number
  default     = 1024
  description = "Memory in MB for ECS task"
}

variable "min_capacity" {
  type        = number
  default     = 2
  description = "Minimum number of ECS tasks"
}

variable "max_capacity" {
  type        = number
  default     = 10
  description = "Maximum number of ECS tasks"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance class"
}

variable "db_username" {
  type        = string
  default     = "agriuser"
  sensitive   = true
  description = "Database master username"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database master password"
}

variable "django_superuser_username" {
  type        = string
  default     = "admin"
  sensitive   = false
  description = "Django superuser username for admin panel access"
}

variable "django_superuser_email" {
  type        = string
  sensitive   = false
  description = "Django superuser email"
}

variable "django_superuser_password" {
  type        = string
  sensitive   = true
  description = "Django superuser password for admin panel access"
}
