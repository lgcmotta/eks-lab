output "alb_info" {
  value = {
    dns_name = module.alb.dns_name
    zone_id  = module.alb.zone_id
  }
}

output "ecr_info" {
  value = {
    repository_urls = module.ecr.repository_urls
    registry_arns   = module.ecr.registry_arns
  }
}
