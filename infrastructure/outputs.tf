output "vpc_info" {
  value = {
    id                 = module.vpc.vpc_id
    public_subnet_ids  = module.vpc.public_subnet_ids
    private_subnet_ids = module.vpc.private_subnet_ids
  }
}

output "eks_info" {
  value = {
    id                 = module.eks.cluster_id
    endpoint           = module.eks.cluster_endpoint
    ca_certificate     = module.eks.cluster_ca_certificate
    asg_name           = module.eks.node_group_asg_name
    security_group_ids = module.eks.cluster_security_group_ids
  }
}
