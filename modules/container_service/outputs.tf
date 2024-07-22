# ./modules/container_service/outputs.tf
output "redis_private_ip" {
  description = "Private IP of the Redis container"
  value       = aws_ecs_task_definition.redis.network_configuration[0].private_ip_address
}