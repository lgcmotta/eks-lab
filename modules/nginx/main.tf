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

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "this" {
  chart            = "ingress-nginx"
  name             = "ingress-nginx"
  version          = "4.13.0"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = false
  depends_on       = [kubernetes_namespace_v1.this]
  values = [
    <<EOF
controller:
  metrics:
    port: 10254
    portName: metrics
    enabled: true
    service:
      enabled: true
      servicePort: 10254
      type: NodePort
      nodePort: 32081
  service:
    type: NodePort
    nodePorts:
      http: 32080
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-healthcheck-port: "32081"
EOF
  ]
}
