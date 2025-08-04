terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.aws.region
  default_tags {
    tags = merge(var.aws.tags, {})
  }
}

module "alb" {
  source                     = "../modules/alb"
  vpc_id                     = var.vpc_info.id
  name                       = var.alb_name
  subnet_ids                 = var.vpc_info.public_subnet_ids
  node_group_asg_name        = var.eks_info.asg_name
  cluster_security_group_ids = var.eks_info.security_group_ids
}

module "ecr" {
  source       = "../modules/ecr"
  repositories = var.ecr_repositories
}
