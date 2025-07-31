variable "aws" {
  type = object({
    bucket          = string
    key             = string
    region          = string
    assume_role_arn = string
    tags            = map(string)
  })
}

variable "vpc" {
  type = object({
    name       = string
    cidr_block = string
  })
}

variable "igw" {
  type = object({
    name = string
  })
}

variable "eks" {
  type = object({
    cluster_name = string
  })
}
