terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

backend "s3" {
  endpoints = {
    s3 = "https://storage.yandexcloud.net"
  }
  bucket = "conf-storage-bucket"
  region = "ru-central1"
  key    = "terraform.tfstate"
  access_key = "SecretKey"
  secret_key = "SecretKey"

  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true # необходимая опция Terraform для версии 1.6.1 и старше.
  skip_s3_checksum            = true # необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.
  }

  required_version = ">=0.13"
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}