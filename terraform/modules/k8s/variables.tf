variable "name_prefix" {
  type = string
}

variable "network_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = map(string)
}

variable "service_account_id" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "node_count" {
  type = object({
    min     = number
    max     = number
    initial = number
  })
}

variable "node_resources" {
  type = object({
    cores  = number
    memory = number
    disk   = number
  })
}

variable "zone" {
  type = string
}

variable "tags" {
  type = map(string)
}