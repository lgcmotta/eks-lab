output "rancher_password_arn" {
  value = module.rancher_secret.secret_arn
}

output "nginx" {
  value = {
    namespace = module.nginx.namespace
    ports = {
      health_check = module.nginx.ports.health_check
      http         = module.nginx.ports.http
    }
  }
}
