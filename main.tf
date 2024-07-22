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
  redis_static_ip    = var.redis_static_ip
  tags = {
    Owner = "AR"
  }
}

output "redis_private_ip" {
  description = "Private IP of the Redis container"
  value       = module.container_service.redis_private_ip
}