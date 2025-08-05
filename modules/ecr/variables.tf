variable "repositories" {
  type = list(object({
    name                 = string
    image_tag_mutability = string
  }))
}
