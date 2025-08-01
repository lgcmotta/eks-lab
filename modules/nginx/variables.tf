variable "cluster" {
  type = object({
    name           = string
    endpoint       = string
    ca_certificate = string
  })
}
