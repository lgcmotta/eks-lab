output "cluster_id" {
  value = aws_eks_cluster.this.id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cluster_security_group_ids" {
  value = flatten([for vpc in aws_eks_cluster.this.vpc_config : vpc.cluster_security_group_id])
}

output "node_group_asg_name" {
  value = aws_eks_node_group.this.resources[0].autoscaling_groups[0].name
}

output "node_security_group_id" {
  value = aws_eks_node_group.this.resources[0].remote_access_security_group_id
}

# output "load_balancer_controller_role_arn" {
#   value = module.iam_load_balancer.role_arn
# }
