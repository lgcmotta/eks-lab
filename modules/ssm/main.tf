resource "random_password" "this" {
  length      = 12
  special     = true
  min_special = 3
  min_upper   = 3
  min_numeric = 3
}

resource "aws_ssm_parameter" "this" {
  name  = var.secret_name
  type  = "String"
  value = random_password.this.result
}
