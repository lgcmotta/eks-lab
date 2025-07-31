variable "eks" {
  type = object({
    name                      = string
    role_name                 = string
    version                   = string
    authentication_mode       = string
    enabled_cluster_log_types = list(string)
  })
}

variable "node_group" {
  type = object({
    name           = string
    instance_types = list(string)
    capacity_type  = string
    role_name      = string
    scaling = object({
      desired = number
      max     = number
      min     = number
    })
  })
}

variable "subnet_ids" {
  type = list(string)
}
