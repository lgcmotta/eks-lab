output "cluster" {
  value = {
    id                     = module.eks.cluster_id
    endpoint               = module.eks.cluster_endpoint
    ca_certificate         = module.eks.cluster_ca_certificate
    autoscaling_group_name = module.eks.node_group_asg_name
    security_group_ids     = module.eks.cluster_security_group_ids
    issuer                 = module.eks.cluster_oidc_issuer_url
  }
}
