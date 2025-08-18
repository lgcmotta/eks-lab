output "password" {
  value     = random_password.this.result
  sensitive = true
}

output "secret_arn" {
  value = aws_ssm_parameter.this.arn
}

