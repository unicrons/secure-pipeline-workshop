variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
  
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "workshop-app"
}

variable "task_cpu" {
  description = "CPU units for ECS task (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory for ECS task in MB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "ecr_repository_url" {
  description = "ECR repository URL for the application image"
  type        = string
  default     = ""
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "load_balancer_name" {
  description = "Name of the existing Application Load Balancer"
  type        = string
  default     = "platform-alb"
}

variable "target_group_name" {
  description = "Name of the existing Target Group"
  type        = string
  default     = "platform-tg"
}

variable "ecr_kms_key_arn" {
  description = "ARN of the existing KMS key for ECR encryption"
  type        = string
  default     = ""
}

variable "logs_kms_key_arn" {
  description = "ARN of the existing KMS key for CloudWatch logs encryption"
  type        = string
  default     = ""
}


