output "ports" {
  value = {
    health_check = var.ports.health_check
    http         = var.ports.http
  }
}

output "namespace" {
  value = "ingress-nginx"
}
