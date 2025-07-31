output "repository_urls" {
  value = [for registry in aws_ecr_repository.this : registry.repository_url]
}

output "registry_arns" {
  value = [for registry in aws_ecr_repository.this : registry.arn]
}

