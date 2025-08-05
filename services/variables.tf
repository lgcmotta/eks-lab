variable "aws" {
  type = object({
    region = string
    tags   = map(string)
  })
}

variable "vpc_info" {
  type = object({
    id                 = string
    public_subnet_ids  = list(string)
    private_subnet_ids = list(string)
  })
}

variable "eks_info" {
  type = object({
    asg_name           = string
    security_group_ids = list(string)
  })
}

variable "nginx_info" {
  type = object({
    namespace = string
    deployed  = bool
  })
}

variable "alb_name" {
  type = string
}

variable "ecr_repositories" {
  type = list(object({
    name                 = string
    image_tag_mutability = string
  }))
}
