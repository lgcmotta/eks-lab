variable "vpc" {
  type = object({
    name                = string
    cidr_block          = string
    igw_name            = string
    public_subnet_tags  = map(string)
    private_subnet_tags = map(string)
  })
}
