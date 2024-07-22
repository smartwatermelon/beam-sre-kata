# ./main.tf
module "networking" {
  source = "./modules/networking"

  project_name = "ar-sre-kata"
  tags = {
    Owner = "AR"
  }
}

module "container_service" {
  source = "./modules/container_service"

  project_name       = "ar-sre-kata"
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  redis_subnet_id    = module.networking.redis_subnet_id
  tags = {
    Owner = "AR"
  }
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.container_service.alb_dns_name
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = module.container_service.ecr_repository_url
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.container_service.ecs_cluster_name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = module.container_service.ecs_service_name
}