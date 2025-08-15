output "password" {
  value     = random_password.this.result
  sensitive = true
}

output "secret_arn" {
  value = aws_secretsmanager_secret.this.arn
}

