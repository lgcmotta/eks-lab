resource "aws_ecr_repository" "this" {
  for_each = {
    for idx, repo in var.repositories : idx => repo
  }
  name                 = each.value.name
  image_tag_mutability = each.value.image_tag_mutability
}
