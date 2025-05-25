terraform {
  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "terraform-state-momo-dev"
    region                      = "ru-central1"
    key                         = "k8s/terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}