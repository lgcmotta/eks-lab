terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket       = var.aws.bucket
    key          = var.aws.key
    region       = var.aws.region
    use_lockfile = true
  }
}

module "vpc" {
  source = "./modules/vpc"
  vpc = {
    name       = var.vpc.name
    cidr_block = var.vpc.cidr_block
    public_subnet_tags = {
      "kubernetes.io/role/elb" = "1"
    }
    private_subnet_tags = {
      "kubernetes.io/role/internal-elb"               = "1"
      "kubernetes.io/cluster/${var.eks.cluster_name}" = "shared"
    }
  }
  igw = {
    name = var.igw.name
  }
}

module "eks" {
  source     = "./modules/eks"
  subnet_ids = module.vpc.private_subnet_ids
  eks = {
    name                = var.eks.cluster_name
    version             = "1.33"
    role_name           = "devops-cluster-role"
    authentication_mode = "API_AND_CONFIG_MAP"

    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  }
  node_group = {
    name           = "devops-node-group"
    role_name      = "devops-ng-role"
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

module "ecr" {
  source = "./modules/ecr"
  repositories = [
    {
      name                 = "motta/dvn-workshop/backend"
      image_tag_mutability = "MUTABLE"
    },
    {
      name                 = "motta/dvn-workshop/frontend"
      image_tag_mutability = "MUTABLE"
    }
  ]
  depends_on = [module.eks]
}
