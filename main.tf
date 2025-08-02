terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
  backend "s3" {
    bucket       = var.aws.bucket
    key          = var.aws.key
    region       = var.aws.region
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws.region
  assume_role {
    role_arn = var.aws.assume_role_arn
  }
  default_tags {
    tags = merge(var.aws.tags, {})
  }
}

module "vpc" {
  source = "./modules/vpc"
  vpc = {
    name       = "eks-lab-vpc"
    cidr_block = "10.0.0.0/16"
    igw_name   = "eks-lab-igw"
    public_subnet_tags = {
      "kubernetes.io/role/elb" = "1"
    }
    private_subnet_tags = {
      "kubernetes.io/role/internal-elb" = "1"
      "kubernetes.io/cluster/eks-lab"   = "shared"
    }
  }
}

module "eks" {
  source     = "./modules/eks"
  subnet_ids = module.vpc.private_subnet_ids
  eks = {
    name                      = "eks-lab"
    version                   = "1.33"
    role_name                 = "EKSLabRole"
    authentication_mode       = "API_AND_CONFIG_MAP"
    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  }
  node_group = {
    name           = "eks-lab-node-group"
    role_name      = "EKSLabNodeGroupRole"
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    scaling = {
      desired = 2
      max     = 2
      min     = 2
    }
  }
  depends_on = [module.vpc]
}


module "nginx" {
  source = "./modules/nginx"
  cluster = {
    name           = module.eks.cluster_id
    endpoint       = module.eks.cluster_endpoint
    ca_certificate = module.eks.cluster_ca_certificate
  }
}

module "alb" {
  source                     = "./modules/alb"
  vpc_id                     = module.vpc.vpc_id
  name                       = "eks-lab"
  subnet_ids                 = module.vpc.public_subnet_ids
  node_group_asg_name        = module.eks.node_group_asg_name
  cluster_security_group_ids = module.eks.cluster_security_group_ids
}

module "ecr" {
  source       = "./modules/ecr"
  repositories = var.ecr_repositories
  depends_on   = [module.alb]
}
