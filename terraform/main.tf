# main.tf
locals {
  common_tags = {
    Environment = var.environment
    Project     = "momo-store"
    ManagedBy   = "terraform"
  }
  
  name_prefix = "${var.environment}-momo"
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

# Data sources
data "yandex_client_config" "client" {}

# Networking module
module "networking" {
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
  
  name_prefix = local.name_prefix
  network_id  = module.networking.vpc_id
  vpc_cidr    = var.network_config.vpc_cidr
  
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
  
  name_prefix             = local.name_prefix
  network_id              = module.networking.vpc_id
  subnet_id               = module.networking.subnet_id
  security_group_ids      = module.security.security_group_ids
  service_account_id      = module.iam.service_account_id
  k8s_version            = var.k8s_version
  node_count             = var.node_count
  node_resources         = var.node_resources
  zone                   = var.zone
  
  tags = local.common_tags
  
  depends_on = [
    module.networking,
    module.security,
    module.iam
  ]
}