# variables.tf
variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Folder ID"
  type        = string
}

variable "zone" {
  description = "Yandex availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "k8s_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.27"
}

variable "node_count" {
  description = "Node group configuration"
  type = object({
    min     = number
    max     = number
    initial = number
  })
  default = {
    min     = 1
    max     = 3
    initial = 1
  }
}

variable "node_resources" {
  description = "Node resources configuration"
  type = object({
    cores  = number
    memory = number
    disk   = number
  })
  default = {
    cores  = 4
    memory = 8
    disk   = 64
  }
}

variable "network_config" {
  description = "Network configuration"
  type = object({
    vpc_cidr    = string
    subnet_cidr = string
  })
  default = {
    vpc_cidr    = "10.1.0.0/16"
    subnet_cidr = "10.1.1.0/24"
  }
}