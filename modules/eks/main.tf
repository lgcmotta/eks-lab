data "aws_iam_policy_document" "this" {
  version = "2012-10-17"
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    effect = "Allow"
    principals {
      identifiers = ["eks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.eks.role_name
  assume_role_policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.this.name
}

resource "aws_eks_cluster" "this" {
  name                      = var.eks.name
  version                   = var.eks.version
  role_arn                  = aws_iam_role.this.arn
  enabled_cluster_log_types = var.eks.enabled_cluster_log_types

  access_config {
    authentication_mode = var.eks.authentication_mode
  }

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [aws_iam_role_policy_attachment.this]
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.node_group.name
  node_role_arn   = aws_iam_role.node.arn
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
  depends_on = [
    aws_iam_role_policy_attachment.node["AmazonEKSWorkerNodePolicy"],
    aws_iam_role_policy_attachment.node["AmazonEKS_CNI_Policy"],
    aws_iam_role_policy_attachment.node["AmazonEC2ContainerRegistryReadOnly"]
  ]
}

resource "aws_iam_role" "node" {
  name               = var.node_group.role_name
  assume_role_policy = data.aws_iam_policy_document.node.json
}

data "aws_iam_policy_document" "node" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = toset([
    "AmazonEKSWorkerNodePolicy",
    "AmazonEKS_CNI_Policy",
    "AmazonEC2ContainerRegistryReadOnly",
  ])

  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/${each.key}"
}

resource "aws_iam_openid_connect_provider" "this" {
  url            = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]
}

locals {
  oidc_url = replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}

data "aws_iam_policy_document" "alb_controller_assume_role" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      identifiers = [aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
      variable = "${local.oidc_url}:sub"
    }
    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "${local.oidc_url}:aud"
    }
  }
}

resource "aws_iam_policy" "alb_controller" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("${path.module}/alb-controller-iam.json")
}

resource "aws_iam_role" "alb_controller" {
  name               = "${var.eks.name}-alb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume_role.json
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  policy_arn = aws_iam_policy.alb_controller.arn
  role       = aws_iam_role.alb_controller.name
}
