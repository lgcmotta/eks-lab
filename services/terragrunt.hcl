include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "infrastructure" {
  config_path = "../infrastructure"

  mock_outputs = {
    vpc_info = {
      id = "vpc-mock123"
      public_subnet_ids = ["public-subnet-1"]
      private_subnet_ids = ["private-subnet-2"]
    }
    cluster_info = {
      asg_name = "mock-asg"
      security_group_ids = ["sg-mock123"]
    }
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan"]
}

dependency "platform" {
  config_path = "../platform"

  mock_outputs = {
    nginx_info = {
      namespace = "ingress-nginx"
      deployed  = true
    }
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan"]
}

inputs = {
  aws = {
    region = "us-east-1"
    tags = {
      managed_by = "opentofu"
      context    = "lab"
      enviroment = "dev"
    }
  }
  vpc_info   = dependency.infrastructure.outputs.vpc_info
  eks_info   = dependency.infrastructure.outputs.eks_info
  nginx_info = dependency.platform.outputs.nginx_info
  alb_name   = "eks-lab"
  ecr_repositories = [
    {
      name                 = "motta/demo-api"
      image_tag_mutability = "MUTABLE"
    }
  ]
}

