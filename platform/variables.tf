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
    id             = string
    endpoint       = string
    ca_certificate = string
    issuer         = string
  })
}
