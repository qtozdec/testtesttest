# modules/iam/main.tf - исправленная версия
resource "yandex_iam_service_account" "k8s" {
  name        = "${var.name_prefix}-k8s-sa"
  description = "Service account for K8s cluster"
  labels      = var.tags
}

# Минимальные права вместо editor
resource "yandex_resourcemanager_folder_iam_binding" "k8s_compute_admin" {
  folder_id = var.folder_id
  role      = "compute.admin"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s.id}"]
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s_vpc_admin" {
  folder_id = var.folder_id
  role      = "vpc.admin"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s.id}"]
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s_load_balancer_admin" {
  folder_id = var.folder_id
  role      = "load-balancer.admin"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s.id}"]
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s_images_puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s.id}"]
}

# Отдельный service account для node group с минимальными правами
resource "yandex_iam_service_account" "k8s_nodes" {
  name        = "${var.name_prefix}-k8s-nodes-sa"
  description = "Service account for K8s nodes"
  labels      = var.tags
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s_nodes_puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s_nodes.id}"]
}

resource "yandex_iam_service_account_static_access_key" "k8s" {
  service_account_id = yandex_iam_service_account.k8s.id
  description        = "Static access key for K8s service account"
}