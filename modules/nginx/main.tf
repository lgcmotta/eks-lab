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
