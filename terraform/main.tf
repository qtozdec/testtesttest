# terraform/main.tf - обновленная версия с data sources
locals {
  common_tags = {
    Environment = var.environment
    Project     = "momo-store"
    ManagedBy   = "terraform"
    CreatedBy   = data.yandex_client_config.client.login
    CreatedAt   = timestamp()
  }
  
  name_prefix = "${var.environment}-momo"
  
  # Автоматическое определение последней версии K8s (если не указана)
  k8s_version = var.k8s_version != "auto" ? var.k8s_version : "1.28"  # fallback
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

# === CONDITIONAL MODULES ===

# Networking module (создается только если не используется внешняя сеть)
module "networking" {
  count = var.use_external_network ? 0 : 1
  
  source = "./modules/networking"
  
  name_prefix    = local.name_prefix
  vpc_cidr       = var.network_config.vpc_cidr
  subnet_cidr    = var.network_config.subnet_cidr
  zone           = var.zone
  
  tags = local.common_tags
}

# Security module
module "security" {
  source = "./modules/security"
  
  name_prefix         = local.name_prefix
  network_id          = local.network_id
  vpc_cidr           = var.network_config.vpc_cidr
  pod_cidr           = var.pod_cidr
  service_cidr       = var.service_cidr
  allowed_api_cidrs  = var.allowed_api_cidrs
  enable_ssh         = var.enable_ssh
  ssh_allowed_cidrs  = var.ssh_allowed_cidrs
  enable_nodeport    = var.enable_nodeport
  nodeport_allowed_cidrs = var.nodeport_allowed_cidrs
  
  tags = local.common_tags
}

# IAM module
module "iam" {
  source = "./modules/iam"
  
  name_prefix = local.name_prefix
  folder_id   = var.folder_id
  
  tags = local.common_tags
}

# K8s module
module "k8s" {
  source = "./modules/k8s"
  
  name_prefix                = local.name_prefix
  network_id                 = local.network_id
  subnet_id                  = local.subnet_id
  security_group_ids         = module.security.security_group_ids
  service_account_id         = module.iam.service_account_id
  node_service_account_id    = module.iam.node_service_account_id
  k8s_version               = local.k8s_version
  node_count                = var.node_count
  node_resources            = var.node_resources
  zone                      = var.zone
  ssh_keys                  = var.ssh_keys
  kms_key_id               = local.kms_key_id
  auto_upgrade             = var.auto_upgrade
  maintenance_window       = var.maintenance_window
  
  tags = local.common_tags
  
  depends_on = [
    module.security,
    module.iam
  ]
}

# === ADDITIONAL VARIABLES FOR REMOTE STATE ===

variable "use_external_network" {
  description = "Use external network from remote state"
  type        = bool
  default     = false
}

variable "use_shared_infrastructure" {
  description = "Use shared infrastructure from remote state"
  type        = bool
  default     = false
}

variable "use_security_baseline" {
  description = "Use security baseline from remote state"
  type        = bool
  default     = false
}