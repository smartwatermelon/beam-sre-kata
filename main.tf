# ./main.tf

# Networking module for VPC and subnet configuration
module "networking" {
  source = "./modules/networking"

  project_name = "ar-sre-kata"
  tags = {
    Owner = "AR"
  }
}

# Container service module for ECS and related resources
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

# Serverless module for Lambda functions and related resources
module "serverless" {
  source = "./modules/serverless"

  tags = {
    Owner = "AR"
  }
}