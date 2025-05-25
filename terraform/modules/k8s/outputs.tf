output "cluster_id" {
  value = yandex_kubernetes_cluster.main.id
}

output "cluster_endpoint" {
  value = yandex_kubernetes_cluster.main.master[0].external_v4_endpoint
}

output "cluster_ca_certificate" {
  value     = yandex_kubernetes_cluster.main.master[0].cluster_ca_certificate
  sensitive = true
}