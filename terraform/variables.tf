# terraform/variables.tf - дополненная версия
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

# === НОВЫЕ ПЕРЕМЕННЫЕ ===

variable "allowed_api_cidrs" {
  description = "CIDR blocks allowed to access K8s API"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # В production ограничьте до конкретных IP офиса/VPN
}

variable "ssh_keys" {
  description = "SSH public keys for nodes (format: username:ssh-rsa AAAA...)"
  type        = string
  default     = null
  sensitive   = true
}

variable "kms_key_id" {
  description = "KMS key ID for etcd encryption (optional)"
  type        = string
  default     = null
}

variable "pod_cidr" {
  description = "CIDR for pod network"
  type        = string
  default     = "10.112.0.0/16"  # дефолтный CIDR для Yandex K8s
}

variable "service_cidr" {
  description = "CIDR for service network"
  type        = string
  default     = "10.96.0.0/16"   # дефолтный CIDR для Yandex K8s
}

variable "enable_ssh" {
  description = "Enable SSH access to nodes"
  type        = bool
  default     = false  # В production отключен по умолчанию
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["10.0.0.0/8"]  # только приватные сети
}

variable "enable_nodeport" {
  description = "Enable NodePort security group"
  type        = bool
  default     = false
}

variable "nodeport_allowed_cidrs" {
  description = "CIDR blocks allowed for NodePort access"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "auto_upgrade" {
  description = "Enable automatic upgrades"
  type        = bool
  default     = true
}

variable "maintenance_window" {
  description = "Maintenance window configuration"
  type = object({
    day        = string
    start_time = string
    duration   = string
  })
  default = {
    day        = "sunday"
    start_time = "03:00"
    duration   = "4h"
  }
}