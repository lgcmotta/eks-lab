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
    name      = "services-cluster"
    version   = "1.33"
    role_name = "EKSLabServicesClusterRole"
  }
  node_group = {
    name          = "service-nodes"
    role_name     = "EKSLabServiceNodeGroupRole"
    capacity_type = "ON_DEMAND"
    instance_types = ["t3.medium"]
    scaling = {
      desired = 2
      max     = 2
      min     = 2
    }
  }
}
