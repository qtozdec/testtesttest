# modules/k8s/main.tf - исправленная версия
resource "yandex_kubernetes_cluster" "main" {
  name        = "${var.name_prefix}-cluster"
  description = "Managed K8s cluster for ${var.name_prefix}"
  network_id  = var.network_id
  labels      = var.tags

  master {
    version = var.k8s_version
    zonal {
      zone      = var.zone
      subnet_id = var.subnet_id
    }
    
    # Убираем public_ip для production
    public_ip = var.master_public_ip
    
    security_group_ids = [var.security_group_ids.main]
    
    maintenance_policy {
      auto_upgrade = var.auto_upgrade
      
      maintenance_window {
        day        = var.maintenance_window.day
        start_time = var.maintenance_window.start_time
        duration   = var.maintenance_window.duration
      }
    }
  }

  service_account_id      = var.service_account_id
  node_service_account_id = var.node_service_account_id  # отдельный SA
  
  release_channel         = var.release_channel
  network_policy_provider = "CALICO"
  
  # Включаем network policy для безопасности
  network_implementation = "cilium"
  
  kms_provider {
    key_id = var.kms_key_id  # шифрование etcd
  }
}

resource "yandex_kubernetes_node_group" "main" {
  name        = "${var.name_prefix}-node-group"
  description = "Node group for ${var.name_prefix} cluster"
  cluster_id  = yandex_kubernetes_cluster.main.id
  version     = var.k8s_version
  labels      = var.tags

  scale_policy {
    auto_scale {
      min     = var.node_count.min
      max     = var.node_count.max
      initial = var.node_count.initial
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  maintenance_policy {
    auto_upgrade = var.auto_upgrade
    auto_repair  = true
    
    maintenance_window {
      day        = var.maintenance_window.day
      start_time = var.maintenance_window.start_time
      duration   = var.maintenance_window.duration
    }
  }

  instance_template {
    platform_id = var.platform_id
    
    network_interface {
      nat                = var.nodes_nat
      subnet_ids         = [var.subnet_id]
      security_group_ids = [
        var.security_group_ids.main,
        var.security_group_ids.public
      ]
    }

    resources {
      cores         = var.node_resources.cores
      memory        = var.node_resources.memory
      core_fraction = var.node_resources.core_fraction
    }

    boot_disk {
      type = var.node_resources.disk_type
      size = var.node_resources.disk_size
    }

    scheduling_policy {
      preemptible = var.preemptible_nodes
    }
    
    # Безопасная передача SSH ключей
    metadata = merge(
      var.ssh_keys != null ? {
        ssh-keys = var.ssh_keys
      } : {},
      var.node_metadata
    )

    # Taints для разделения нагрузки
    dynamic "node_taints" {
      for_each = var.node_taints
      content {
        key    = node_taints.value.key
        value  = node_taints.value.value
        effect = node_taints.value.effect
      }
    }
  }

  # Deploy policy для управления обновлениями
  deploy_policy {
    max_expansion   = var.deploy_policy.max_expansion
    max_unavailable = var.deploy_policy.max_unavailable
  }
}