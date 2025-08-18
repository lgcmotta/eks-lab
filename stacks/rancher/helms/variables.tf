variable "aws" {
  type = object({
    region = string
    tags   = map(string)
  })
}

variable "eks" {
  type = object({
    id                     = string
    endpoint               = string
    ca_certificate         = string
    autoscaling_group_name = string
    security_group_ids     = list(string)
    issuer                 = string
  })
}

variable "nginx" {
  type = object({
    health_check_port = number
    http_port         = number
  })
}

variable "rancher" {
  type = object({
    secret_path = string
  })
}
