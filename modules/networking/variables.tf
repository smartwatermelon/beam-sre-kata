# ./modules/networking/variables.tf
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ar-sre-kata"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "redis_subnet_cidr" {
  description = "CIDR block for the Redis subnet"
  type        = string
  default     = "10.0.7.0/24"
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default = {
    Owner = "AR"
  }
}