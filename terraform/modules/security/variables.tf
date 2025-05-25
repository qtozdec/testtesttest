variable "name_prefix" {
  type = string
}

variable "network_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "tags" {
  type = map(string)
}