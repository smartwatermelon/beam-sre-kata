# ./main.tf
module "networking" {
  source = "./modules/networking"

  project_name = "ar-sre-kata"
  tags = {
    Owner = "AR"
  }
}