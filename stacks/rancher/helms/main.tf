terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9"
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
    host                   = var.eks.endpoint
    cluster_ca_certificate = base64decode(var.eks.ca_certificate)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks.id]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = var.eks.endpoint
  cluster_ca_certificate = base64decode(var.eks.ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.eks.id]
    command     = "aws"
  }
}

module "metrics" {
  source = "../../../modules/metrics"
}

module "nginx" {
  source = "../../../modules/nginx"
  ports = {
    health_check = var.nginx.health_check_port
    http         = var.nginx.http_port
  }
  depends_on = [module.metrics]
}

module "rancher_secret" {
  source      = "../../../modules/ssm"
  secret_name = var.rancher.secret_path
}

module "rancher" {
  source             = "../../../modules/rancher"
  bootstrap_password = module.rancher_secret.password
  depends_on         = [module.nginx, module.rancher_secret]
}
