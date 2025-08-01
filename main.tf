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
    name                      = var.eks.cluster_name
    version                   = "1.33"
    role_name                 = "motta-cluster-role"
    authentication_mode       = "API_AND_CONFIG_MAP"
    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  }
  node_group = {
    name           = "motta-node-group"
    role_name      = "motta-ng-role"
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
      name                 = "motta/workshop/backend"
      image_tag_mutability = "MUTABLE"
    }
  ]
  depends_on = [module.eks]
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
  name                       = "workshop"
  subnet_ids                 = module.vpc.public_subnet_ids
  node_group_asg_name        = module.eks.node_group_asg_name
  cluster_security_group_ids = module.eks.cluster_security_group_ids
  depends_on                 = [module.vpc, module.eks, module.nginx]
}

# module "load_balancer_controller" {
#   source     = "./modules/lb_controller"
#   aws_region = var.aws.region
#   cluster = {
#     name           = module.eks.cluster_id
#     endpoint       = module.eks.cluster_endpoint
#     ca_certificate = module.eks.cluster_ca_certificate
#     role_arn       = module.eks.load_balancer_controller_role_arn
#   }
#   vpc_id = module.vpc.vpc_id
# }
