output "nginx" {
  value = {
    namespace = module.nginx.namespace
    ports = {
      health_check = module.nginx.ports.health_check
      http         = module.nginx.ports.http
    }
  }
}
