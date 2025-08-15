include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    vpc_id = "vpc-mock123"
    public_subnet_ids = ["public-subnet-1"]
    private_subnet_ids = ["private-subnet-2"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan"]
}

dependency "services" {
  config_path = "../services/helms"
  mock_outputs = {
    nginx = {
      namespace = "ingress-nginx"
      ports = {
        health_check = 32080
        http         = 32081
      }
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
  vpc = {
    id                 = dependency.network.outputs.vpc_id
    private_subnet_ids = dependency.network.outputs.private_subnet_ids
  }
  eks = {
    name      = "rancher-cluster"
    version   = "1.33"
    role_name = "EKSLabRancherClusterRole"
  }
  node_group = {
    name          = "rancher-nodes"
    role_name     = "EKSLabRancherNodeGroupRole"
    capacity_type = "ON_DEMAND"
    instance_types = ["t3.medium"]
    scaling = {
      desired = 1
      max     = 2
      min     = 1
    }
  }
}
