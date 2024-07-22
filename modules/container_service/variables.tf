# ./modules/container_service/variables.tf
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
}

variable "app_port" {
  description = "Port on which the application listens"
  type        = number
  default     = 4567
}

variable "redis_port" {
  description = "Port on which Redis listens"
  type        = number
  default     = 6379
}

variable "app_image" {
  description = "Docker image for the application"
  type        = string
  default     = "beamdental/sre-kata-app"
}

variable "redis_image" {
  description = "Docker image for Redis"
  type        = string
  default     = "redis:latest"
}

variable "redis_subnet_id" {
  description = "ID of the subnet where Redis will be deployed"
  type        = string
}