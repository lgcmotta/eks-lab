variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "node_group_asg_name" {
  type = string
}

variable "cluster_security_group_ids" {
  type = list(string)
}
