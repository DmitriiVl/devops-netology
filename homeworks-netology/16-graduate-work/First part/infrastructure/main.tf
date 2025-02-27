// Создание сети
resource "yandex_vpc_network" "netology" {
  name = var.vpc_name
}

// Создание публичной подсети
resource "yandex_vpc_subnet" "public" {
  name           = var.vpc_name_public
  zone           = var.default_zone
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = var.default_cidr_public
}

// Создание частной подсети
resource "yandex_vpc_subnet" "private" {
  name           = var.vpc_name_private
  zone           = var.cloud_yandex_zoned
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = var.default_cidr_private
}

