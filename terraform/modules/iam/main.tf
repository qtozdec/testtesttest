resource "yandex_iam_service_account" "k8s" {
  name        = "${var.name_prefix}-k8s-sa"
  description = "Service account for K8s cluster"
  labels      = var.tags
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s_editor" {
  folder_id = var.folder_id
  role      = "editor"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s.id}"]
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s_images_puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s.id}"]
}

resource "yandex_iam_service_account_static_access_key" "k8s" {
  service_account_id = yandex_iam_service_account.k8s.id
  description        = "Static access key for K8s service account"
}
