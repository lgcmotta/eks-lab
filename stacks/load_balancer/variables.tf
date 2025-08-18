variable "aws" {
  type = object({
    region = string
    tags   = map(string)
  })
}

variable "alb" {
  type = object({
    name = string
  })
}

variable "route53" {
  type = object({
    domain = string
    zone   = string
  })
}

variable "vpc" {
  type = object({
    id                = string
    public_subnet_ids = list(string)
  })
}

variable "services" {
  type = object({
    security_group_ids = list(string)
  })
}

variable "rancher" {
  type = object({
    security_group_ids = list(string)
  })
}

variable "targets" {
  type = list(object({
    name          = string
    dns           = string
    rule_priority = number
    cluster = object({
      security_group_ids     = list(string)
      autoscaling_group_name = string
    })
    ports = object({
      health_check = number
      http         = number
    })
  }))
}
