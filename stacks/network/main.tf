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

module "vpc" {
  source = "../../modules/vpc"
  vpc = {
    name             = var.vpc.name
    cidr_block       = var.vpc.cidr_block
    internet_gateway = var.vpc.internet_gateway_name
    public_subnet_tags = {
      "kubernetes.io/role/elb" = "1"
    }
    private_subnet_tags = {
      "kubernetes.io/role/internal-elb"           = "1"
      "kubernetes.io/cluster/${var.eks.services}" = "shared"
      "kubernetes.io/cluster/${var.eks.rancher}"  = "shared"
    }
  }
}
