module "lb_controller_iam" {
  source       = "iam"
  cluster_name = var.cluster.name
  issuer       = var.cluster.issuer
}

resource "helm_release" "this" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.13.3"
  namespace  = "kube-system"

  set = [
    {
      name  = "clusterName"
      value = var.cluster.name
    },
    {
      name  = "serviceAccount.create"
      value = true
    },
    {
      name  = "region"
      value = var.aws_region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = var.cluster.role_arn
    }
  ]
}
