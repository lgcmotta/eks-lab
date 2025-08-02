variable "aws" {
  type = object({
    bucket          = string
    key             = string
    region          = string
    assume_role_arn = string
    tags            = map(string)
  })
}

variable "ecr_repositories" {
  type = list(object({
    name                 = string
    image_tag_mutability = string
  }))
}
