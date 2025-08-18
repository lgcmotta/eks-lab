include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "eks" {
  config_path = "../"
  mock_outputs = {
    cluster = {
      id                     = "services-cluster"
      endpoint               = "https://mock.eks.amazonaws.com"
      ca_certificate         = "LS0tLS1CRUdJTi0="
      autoscaling_group_name = "asg-mock"
      issuer                 = "https://mock.eks.amazonaws.com"
      security_group_ids = ["sg-mock-1", "sg-mock-2"]
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
  eks = {
    id                     = dependency.eks.outputs.cluster.id
    endpoint               = dependency.eks.outputs.cluster.endpoint
    ca_certificate         = dependency.eks.outputs.cluster.ca_certificate
    autoscaling_group_name = dependency.eks.outputs.cluster.autoscaling_group_name
    security_group_ids     = dependency.eks.outputs.cluster.security_group_ids
    issuer                 = dependency.eks.outputs.cluster.issuer
  }
  nginx = {
    health_check_port = 32080
    http_port         = 32081
  }
}
