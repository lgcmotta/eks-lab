variable "ports" {
  type = object({
    health_check = number
    http         = number
  })
}
