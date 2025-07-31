variable "vpc" {
  type = object({
    name       = string
    cidr_block = string
    public_subnet_tags = map(string)
    private_subnet_tags = map(string)
  })
}

variable "igw" {
  type = object({
    name = string
  })
}
