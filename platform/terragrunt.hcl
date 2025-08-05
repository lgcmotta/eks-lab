include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "infrastructure" {
  config_path = "../infrastructure"
  mock_outputs = {
    eks_info = {
      id             = "mock-cluster"
      endpoint       = "https://mock.eks.amazonaws.com"
      ca_certificate = "LS0tLS1CRUdJTi0="
      issuer         = "https://mock.eks.amazonaws.com"
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
  eks_info = dependency.infrastructure.outputs.eks_info
}
