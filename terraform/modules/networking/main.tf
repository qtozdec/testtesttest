resource "yandex_vpc_network" "main" {
  name        = "${var.name_prefix}-network"
  description = "VPC for ${var.name_prefix} cluster"
  labels      = var.tags
}

resource "yandex_vpc_subnet" "main" {
  name           = "${var.name_prefix}-subnet"
  description    = "Subnet for ${var.name_prefix} cluster"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.subnet_cidr]
  
  labels = var.tags
}

# modules/networking/variables.tf
variable "name_prefix" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "zone" {
  type = string
}

variable "tags" {
  type = map(string)
}