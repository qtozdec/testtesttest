variable "name_prefix" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

# modules/iam/outputs.tf
output "service_account_id" {
  value = yandex_iam_service_account.k8s.id
}

output "static_access_key" {
  value = {
    id     = yandex_iam_service_account_static_access_key.k8s.access_key
    secret = yandex_iam_service_account_static_access_key.k8s.secret_key
  }
  sensitive = true
}