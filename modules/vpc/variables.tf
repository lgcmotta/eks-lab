variable "vpc" {
  type = object({
    name                = string
    cidr_block          = string
    internet_gateway    = string
    public_subnet_tags  = map(string)
    private_subnet_tags = map(string)
  })
}
