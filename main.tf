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

  project_name      = "ar-sre-kata"
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  tags = {
    Owner = "AR"
  }
}