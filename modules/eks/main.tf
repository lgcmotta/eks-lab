module "iam_eks" {
  source    = "./iam/eks"
  role_name = var.eks.role_name
}

resource "aws_eks_cluster" "this" {
  name                      = var.eks.name
  version                   = var.eks.version
  role_arn                  = module.iam_eks.role_arn
  enabled_cluster_log_types = var.eks.enabled_cluster_log_types

  access_config {
    authentication_mode = var.eks.authentication_mode
  }

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [module.iam_eks]
}

module "iam_node_group" {
  source     = "./iam/node_group"
  role_name  = var.node_group.role_name
  depends_on = [aws_eks_cluster.this]
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.id
  node_group_name = var.node_group.name
  node_role_arn   = module.iam_node_group.role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.node_group.instance_types
  capacity_type   = var.node_group.capacity_type
  scaling_config {
    desired_size = var.node_group.scaling.desired
    max_size     = var.node_group.scaling.max
    min_size     = var.node_group.scaling.min
  }
  tags = {
    "kubernetes.io/cluster/${var.eks.name}" = "owned"
  }
  depends_on = [aws_eks_cluster.this, module.iam_node_group]
}

module "iam_load_balancer" {
  source       = "./iam/controller"
  cluster_name = aws_eks_cluster.this.id
  issuer       = aws_eks_cluster.this.identity[0].oidc[0].issuer
  depends_on   = [aws_eks_cluster.this, aws_eks_node_group.this]
}
