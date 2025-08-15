resource "random_password" "this" {
  length      = 12
  special     = true
  min_special = 3
  min_upper   = 3
  min_numeric = 3
}

resource "aws_secretsmanager_secret" "this" {
  name = var.secret_name
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = random_password.this.result
}
