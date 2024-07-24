# ./outputs.tf

# Networking outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "redis_subnet_id" {
  description = "ID of the Redis subnet"
  value       = module.networking.redis_subnet_id
}

# Container Service outputs
output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.container_service.ecs_cluster_arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.container_service.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.container_service.ecs_service_name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.container_service.alb_dns_name
}

# Serverless outputs
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.serverless.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.serverless.lambda_function_arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for the Lambda function"
  value       = module.serverless.cloudwatch_log_group_name
}