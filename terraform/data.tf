# terraform/data.tf - новый файл для data sources
terraform {
  required_version = ">= 1.5"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.100"
    }
  }
}

# Получаем информацию о текущем клиенте
data "yandex_client_config" "client" {}

# Получаем доступные версии Kubernetes
data "yandex_kubernetes_cluster" "available_versions" {
  count = 0  # Хак для получения доступных версий через provider
}

# Получаем список доступных зон
data "yandex_compute_zones" "available" {}

# Получаем информацию о последней версии Ubuntu образа для нод
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# === REMOTE STATE DATA SOURCES ===

# Shared infrastructure state (если используется)
data "terraform_remote_state" "shared" {
  count = var.use_shared_infrastructure ? 1 : 0
  
  backend = "s3"
  config = {
    endpoint                    = "storage.yandexcloud.net"
    bucket                     = "terraform-state-shared-${var.environment}"
    region                     = "ru-central1"
    key                        = "shared/terraform.tfstate"
    skip_region_validation     = true
    skip_credentials_validation = true
    skip_metadata_api_check    = true
  }
}

# Network state (если сеть создается отдельно)
data "terraform_remote_state" "network" {
  count = var.use_external_network ? 1 : 0
  
  backend = "s3"
  config = {
    endpoint                    = "storage.yandexcloud.net"
    bucket                     = "terraform-state-network-${var.environment}"
    region                     = "ru-central1"  
    key                        = "network/terraform.tfstate"
    skip_region_validation     = true
    skip_credentials_validation = true
    skip_metadata_api_check    = true
  }
}

# Security baseline state (если есть базовые security группы)
data "terraform_remote_state" "security_baseline" {
  count = var.use_security_baseline ? 1 : 0
  
  backend = "s3"
  config = {
    endpoint                    = "storage.yandexcloud.net"
    bucket                     = "terraform-state-security-${var.environment}"
    region                     = "ru-central1"
    key                        = "security/terraform.tfstate"
    skip_region_validation     = true
    skip_credentials_validation = true
    skip_metadata_api_check    = true
  }
}

# Locals для работы с remote state
locals {
  # Используем внешнюю сеть или создаем новую
  network_id = var.use_external_network ? (
    data.terraform_remote_state.network[0].outputs.vpc_id
  ) : module.networking.vpc_id
  
  subnet_id = var.use_external_network ? (
    data.terraform_remote_state.network[0].outputs.subnet_id
  ) : module.networking.subnet_id
  
  # Базовые security группы (если есть)
  base_security_groups = var.use_security_baseline ? (
    data.terraform_remote_state.security_baseline[0].outputs.base_security_group_ids
  ) : []
  
  # KMS ключ из shared infrastructure
  kms_key_id = var.kms_key_id != null ? var.kms_key_id : (
    var.use_shared_infrastructure ? 
    try(data.terraform_remote_state.shared[0].outputs.k8s_kms_key_id, null) : 
    null
  )
}