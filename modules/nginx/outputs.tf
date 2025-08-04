output "nginx" {
  value = {
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    deployed  = true
  }
}
