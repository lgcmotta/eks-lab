terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.aws.region
  default_tags {
    tags = var.aws.tags
  }
}

data "aws_caller_identity" "this" {}

module "eks" {
  source            = "../../modules/eks"
  cluster_admin_arn = data.aws_caller_identity.this.arn
  subnet_ids        = var.vpc.private_subnet_ids
  eks = {
    name                      = var.eks.name
    version                   = var.eks.version
    role_name                 = var.eks.role_name
    authentication_mode       = "API_AND_CONFIG_MAP"
    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  }
  node_group = {
    name           = var.node_group.name
    role_name      = var.node_group.role_name
    capacity_type  = var.node_group.capacity_type
    instance_types = var.node_group.instance_types
    scaling = {
      desired = var.node_group.scaling.desired
      min     = var.node_group.scaling.min
      max     = var.node_group.scaling.max
    }
  }
}
