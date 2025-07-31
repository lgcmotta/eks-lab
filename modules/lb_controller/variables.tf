variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "cluster" {
  type = object({
    name           = string
    endpoint       = string
    ca_certificate = string
    role_arn       = string
  })
}
