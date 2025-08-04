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

data "aws_caller_identity" "this" {}

module "vpc" {
  source = "../modules/vpc"
  vpc = {
    name       = var.vpc.name
    cidr_block = var.vpc.cidr_block
    igw_name   = var.vpc.internet_gateway_name
    public_subnet_tags = {
      "kubernetes.io/role/elb" = "1"
    }
    private_subnet_tags = {
      "kubernetes.io/role/internal-elb"       = "1"
      "kubernetes.io/cluster/${var.eks.name}" = "shared"
    }
  }
}

module "eks" {
  source            = "../modules/eks"
  subnet_ids        = module.vpc.private_subnet_ids
  cluster_admin_arn = data.aws_caller_identity.this.arn
  eks = {
    name                      = var.eks.name
    version                   = var.eks.version
    role_name                 = var.eks.role_name
    authentication_mode       = "API_AND_CONFIG_MAP"
    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  }
  node_group = {
    name           = var.eks.node_group.name
    role_name      = var.eks.node_group.role_name
    capacity_type  = var.eks.node_group.capacity_type
    instance_types = var.eks.node_group.instance_types
    scaling = {
      desired = var.eks.node_group.scaling.desired
      max     = var.eks.node_group.scaling.max
      min     = var.eks.node_group.scaling.min
    }
  }
  depends_on = [module.vpc]
}
