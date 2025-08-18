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
    services = string
    rancher  = string
  })
}
