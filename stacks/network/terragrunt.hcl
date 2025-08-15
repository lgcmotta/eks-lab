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
    services = "services-cluster"
    rancher  = "rancher-cluster"
  }
}
