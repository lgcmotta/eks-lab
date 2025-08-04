include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
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
    name                  = "eks-lab-vpc"
    cidr_block            = "10.0.0.0/16"
    internet_gateway_name = "eks-lab-igw"
  }
  eks = {
    name      = "eks-lab"
    version   = "1.33"
    role_name = "EKSLabRole"
    node_group = {
      name          = "eks-lab-nodes"
      role_name     = "EKSLabNodeGroupRole"
      capacity_type = "ON_DEMAND"
      instance_types = ["t3.medium"]
      scaling = {
        desired = 2
        max     = 2
        min     = 2
      }
    }
  }
}
