variable "aws" {
  type = object({
    region = string
    tags   = map(string)
  })
}

variable "vpc" {
  type = object({
    name                  = string
    cidr_block            = string
    internet_gateway_name = string
  })
}

variable "eks" {
  type = object({
    name      = string
    version   = string
    role_name = string
    node_group = object({
      name           = string
      role_name      = string
      capacity_type  = string
      instance_types = list(string)
      scaling = object({
        desired = number
        max     = number
        min     = number
      })
    })
  })
}
