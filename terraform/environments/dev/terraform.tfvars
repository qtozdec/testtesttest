cloud_id     = "b1gap14jhae4gb62dvga"
folder_id    = "b1gbmmr5iqp5f2n12m4e"
zone         = "ru-central1-a"
environment  = "dev"
k8s_version  = "1.27"

node_count = {
  min     = 1
  max     = 3
  initial = 1
}

node_resources = {
  cores  = 4
  memory = 8
  disk   = 64
}

network_config = {
  vpc_cidr    = "10.1.0.0/16"
  subnet_cidr = "10.1.1.0/24"
}

# outputs.tf
output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = module.k8s.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate"
  value       = module.k8s.cluster_ca_certificate
  sensitive   = true
}

output "static_access_key" {
  description = "Static access key for service account"
  value       = module.iam.static_access_key
  sensitive   = true
}