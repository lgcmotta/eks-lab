variable "aws" {
  type = object({
    region = string
    tags   = map(string)
  })
}

variable "eks_info" {
  type = object({
    id             = string
    endpoint       = string
    ca_certificate = string
  })
}
