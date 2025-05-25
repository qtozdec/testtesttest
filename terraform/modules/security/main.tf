# modules/security/main.tf - production ready
resource "yandex_vpc_security_group" "k8s_main" {
  name        = "${var.name_prefix}-k8s-main"
  description = "Main security group for K8s cluster"
  network_id  = var.network_id
  labels      = var.tags

  # Load balancer health checks - точные подсети
  ingress {
    description    = "YC Load Balancer health checks"
    protocol       = "TCP"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
    from_port      = 0
    to_port        = 65535
  }

  # Kubernetes API - ограниченный доступ
  ingress {
    description    = "K8s API HTTPS"
    protocol       = "TCP"
    v4_cidr_blocks = var.allowed_api_cidrs
    port           = 443
  }

  ingress {
    description    = "K8s API insecure (если необходимо)"
    protocol       = "TCP"
    v4_cidr_blocks = var.allowed_api_cidrs
    port           = 6443
  }

  # Внутренняя связь кластера
  ingress {
    description       = "Cluster internal communication"
    protocol          = "ANY"
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }

  # Pod-to-pod network
  ingress {
    description    = "Pod network communication"
    protocol       = "ANY"
    v4_cidr_blocks = [var.pod_cidr]
    from_port      = 0
    to_port        = 65535
  }

  # Service network
  ingress {
    description    = "Service network communication"
    protocol       = "ANY"
    v4_cidr_blocks = [var.service_cidr]
    from_port      = 0
    to_port        = 65535
  }

  # ICMP только из приватных сетей
  ingress {
    description    = "ICMP for debugging"
    protocol       = "ICMP"
    v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }

  # SSH доступ (если необходим)
  dynamic "ingress" {
    for_each = var.enable_ssh ? [1] : []
    content {
      description    = "SSH access"
      protocol       = "TCP"
      v4_cidr_blocks = var.ssh_allowed_cidrs
      port           = 22
    }
  }

  egress {
    description    = "All outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

# Группа для ingress controller/ALB
resource "yandex_vpc_security_group" "k8s_ingress" {
  name        = "${var.name_prefix}-k8s-ingress"
  description = "Security group for ingress services"
  network_id  = var.network_id
  labels      = var.tags

  ingress {
    description    = "HTTP"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    description    = "HTTPS"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  # Health checks от ALB
  ingress {
    description    = "ALB health checks"
    protocol       = "TCP"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
    from_port      = 0
    to_port        = 65535
  }
}

# Отдельная группа для NodePort (если используются)
resource "yandex_vpc_security_group" "k8s_nodeport" {
  count = var.enable_nodeport ? 1 : 0
  
  name        = "${var.name_prefix}-k8s-nodeport"
  description = "Security group for NodePort services"
  network_id  = var.network_id
  labels      = var.tags

  ingress {
    description    = "NodePort services"
    protocol       = "TCP"
    v4_cidr_blocks = var.nodeport_allowed_cidrs
    from_port      = 30000
    to_port        = 32767
  }
}