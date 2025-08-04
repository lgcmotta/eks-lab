terraform {
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
  backend "s3" {}
}

provider "aws" {
  region = var.aws.region
  default_tags {
    tags = merge(var.aws.tags, {})
  }
}

provider "helm" {
  kubernetes = {
    host                   = var.eks_info.endpoint
    cluster_ca_certificate = base64decode(var.eks_info.ca_certificate)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks_info.id]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = var.eks_info.endpoint
  cluster_ca_certificate = base64decode(var.eks_info.ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.eks_info.id]
    command     = "aws"
  }
}

module "nginx" {
  source = "../modules/nginx"
  cluster = {
    name           = var.eks_info.id
    endpoint       = var.eks_info.endpoint
    ca_certificate = var.eks_info.ca_certificate
  }
}
