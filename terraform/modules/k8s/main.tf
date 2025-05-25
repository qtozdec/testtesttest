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
    
    public_ip = true
    
    security_group_ids = [var.security_group_ids.main]
    
    maintenance_policy {
      auto_upgrade = true
      
      maintenance_window {
        day        = "monday"
        start_time = "03:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = var.service_account_id
  node_service_account_id = var.service_account_id
  
  release_channel = "REGULAR"
  
  network_policy_provider = "CALICO"
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
    auto_upgrade = true
    auto_repair  = true
    
    maintenance_window {
      day        = "monday"
      start_time = "04:00"
      duration   = "4h"
    }
  }

  instance_template {
    platform_id = "standard-v3"
    
    network_interface {
      nat        = true
      subnet_ids = [var.subnet_id]
      security_group_ids = [
        var.security_group_ids.main,
        var.security_group_ids.public
      ]
    }

    resources {
      cores         = var.node_resources.cores
      memory        = var.node_resources.memory
      core_fraction = 100
    }

    boot_disk {
      type = "network-ssd"
      size = var.node_resources.disk
    }

    scheduling_policy {
      preemptible = false
    }
    
    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
  }
}
