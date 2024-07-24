# ./providers.tf

# Specify required providers and their versions
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = "us-east-2"  # Specify the AWS region as per project requirements
}