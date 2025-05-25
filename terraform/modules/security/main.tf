resource "yandex_vpc_security_group" "k8s_main" {
  name        = "${var.name_prefix}-k8s-main"
  description = "Main security group for K8s cluster"
  network_id  = var.network_id
  labels      = var.tags

  # Health checks from load balancer
  ingress {
    description       = "Load balancer health checks"
    protocol          = "TCP"
    v4_cidr_blocks    = ["198.18.235.0/24", "198.18.248.0/24"]
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }

  # Kubernetes API access
  ingress {
    description    = "K8s API HTTPS"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    description    = "K8s API"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }

  # Internal cluster communication
  ingress {
    description       = "Cluster internal communication"
    protocol          = "ANY"
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }

  # Pod-to-pod communication
  ingress {
    description    = "Pod-to-pod communication"
    protocol       = "ANY"
    v4_cidr_blocks = [var.vpc_cidr]
    from_port      = 0
    to_port        = 65535
  }

  # ICMP for debugging
  ingress {
    description    = "ICMP for debugging"
    protocol       = "ICMP"
    v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }

  # All outbound traffic
  egress {
    description    = "All outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "k8s_public" {
  name        = "${var.name_prefix}-k8s-public"
  description = "Security group for public services"
  network_id  = var.network_id
  labels      = var.tags

  ingress {
    description    = "NodePort services"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30000
    to_port        = 32767
  }
}