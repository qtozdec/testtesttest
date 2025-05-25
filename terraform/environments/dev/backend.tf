# terraform/environments/dev/backend.tf - улучшенная версия
terraform {
  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                     = "terraform-state-momo-dev"
    region                     = "ru-central1"
    key                        = "k8s/terraform.tfstate"
    
    # Включаем шифрование state файла
    encrypt                    = true
    
    # DynamoDB таблица для блокировки (создайте в Yandex Object Storage)
    dynamodb_table             = "terraform-state-lock-momo-dev"
    
    # Опции для Yandex Cloud
    skip_region_validation     = true
    skip_credentials_validation = true
    skip_metadata_api_check    = true
    skip_requesting_account_id = true
    skip_s3_checksum          = true
    
    # Версионирование включено на уровне bucket
    versioning                = true
  }
}