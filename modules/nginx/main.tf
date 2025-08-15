resource "helm_release" "this" {
  chart            = "ingress-nginx"
  name             = "ingress-nginx"
  version          = "4.13.0"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  values = [
    <<EOF
controller:
  config:
    use-forwarded-headers: true
  metrics:
    port: 10254
    portName: metrics
    enabled: true
    service:
      enabled: true
      servicePort: 10254
      type: NodePort
      nodePort: ${var.ports.health_check}
  service:
    type: NodePort
    nodePorts:
      http: ${var.ports.http}
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-healthcheck-port: "${var.ports.health_check}"
EOF
  ]
}
