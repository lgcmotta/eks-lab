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
  config_path = "../services"
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

dependency "rancher" {
  config_path = "../rancher"
  mock_outputs = {
    cluster = {
      id                     = "rancher-cluster"
      endpoint               = "https://mock.eks.amazonaws.com"
      ca_certificate         = "LS0tLS1CRUdJTi0="
      autoscaling_group_name = "asg-mock"
      issuer                 = "https://mock.eks.amazonaws.com"
      security_group_ids = ["sg-mock-1", "sg-mock-2"]
    }
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan"]
}

dependency "services_helm" {
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

dependency "rancher_helm" {
  config_path = "../rancher/helms"
  mock_outputs = {
    nginx = {
      namespace = "ingress-nginx"
      ports = {
        health_check = 32180
        http         = 32181
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
  alb = {
    name = "eks-lab"
  }
  route53 = {
    domain = "mottacode.com"
    zone   = "mottacode.com."
  }
  vpc = {
    id                = dependency.network.outputs.vpc_id
    public_subnet_ids = dependency.network.outputs.public_subnet_ids
  }
  targets = [
    {
      name          = "services"
      dns           = "api.mottacode.com"
      rule_priority = 100
      cluster = {
        security_group_ids     = dependency.services.outputs.cluster.security_group_ids
        autoscaling_group_name = dependency.services.outputs.cluster.autoscaling_group_name
      }
      ports = {
        health_check = dependency.services_helm.outputs.nginx.ports.health_check
        http         = dependency.services_helm.outputs.nginx.ports.http
      }
    },
    {
      name          = "rancher"
      dns           = "rancher.mottacode.com"
      rule_priority = 200
      cluster = {
        security_group_ids     = dependency.rancher.outputs.cluster.security_group_ids
        autoscaling_group_name = dependency.rancher.outputs.cluster.autoscaling_group_name
      }
      ports = {
        health_check = dependency.rancher_helm.outputs.nginx.ports.health_check
        http         = dependency.rancher_helm.outputs.nginx.ports.http
      }
    }
  ]
}
