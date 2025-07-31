provider "helm" {
  kubernetes = {
    host                   = var.cluster.endpoint
    cluster_ca_certificate = base64decode(var.cluster.ca_certificate)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster.name]
      command     = "aws"
    }
  }
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
