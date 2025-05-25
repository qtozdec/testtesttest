output "network_id" {
  description = "ID VPC сети"
  value       = module.network.network_id
}

output "subnet_id" {
  description = "ID подсети"
  value       = module.network.subnet_id
}

output "cluster_id" {
  description = "ID Kubernetes кластера"
  value       = module.cluster.cluster_id
}

output "kubeconfig_path" {
  description = "Путь к kubeconfig"
  value       = local_file.kubeconfig.filename
}
