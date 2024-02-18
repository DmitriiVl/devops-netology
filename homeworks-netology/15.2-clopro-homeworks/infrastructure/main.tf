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
  zone           = var.default_zone
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = var.default_cidr_private
  # route_table_id = yandex_vpc_route_table.rt.id
}

// Создание сервисного аккаунта
resource "yandex_iam_service_account" "bucket-sa" {
  name = "bucket-sa"
}

// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.bucket-sa.id}"
}

// Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.bucket-sa.id
  description        = "static access key for object storage"
}

// Создание бакета с использованием ключа
resource "yandex_storage_bucket" "dmivlad-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "dmivlad-bucket"
}

// Добавление файла-картинки в бакет
resource "yandex_storage_object" "img-mountains" {
    access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
    bucket = yandex_storage_bucket.dmivlad-bucket.bucket
    key = "mountains.jpg"
    source = "~/clopro-homeworks/15.2/infrastructure/mountains.jpg"
    acl    = "public-read"
    depends_on = [yandex_storage_bucket.dmivlad-bucket]
}


# // Создание NAT Instance
# resource "yandex_compute_instance" "nat-gateway" {
#   name = "nat-gateway"
#   platform_id = "standard-v1"
#   resources {
#     cores         = 2
#     memory        = 2
#     core_fraction = 20
#   }  

#   boot_disk {
#     initialize_params {
#       image_id = "fd80mrhj8fl2oe87o4e1"
#     }
#   }

#   network_interface {
#     subnet_id = yandex_vpc_subnet.public.id
#     nat       = true
#     ip_address = "192.168.10.254"
#   }
# }

# // Создание ВМ во внешней сети с публичным IP
# resource "yandex_compute_instance" "vm_pubnet" {
#   name = "vm-from-public-net"
#   platform_id = "standard-v1"
#   resources {
#     cores         = 2
#     memory        = 2
#     core_fraction = 20
#   }

#   boot_disk {
#     initialize_params {
#       image_id = "fd8vljd295nqdaoogf3g"
#     }
#   }
#   network_interface {
#     subnet_id = yandex_vpc_subnet.public.id
#     nat       = true
#   }

#   metadata = {
#     serial-port-enable = 1
#     ssh-keys           = "ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9mi/8PO7m2/yrKy7ZnFr15bvdUrC6DUmqn/5DVKiHAO7hy9e9b+ktQ5WaejyCyrPr4pn474suPPLL2s6ZY71041pwKD2kQ1QeYNL0woHqOFCjlxeXpDAGVwUkwFekyUwCwmM1WWpZ9IqhPB50kN2FHnbzMONFti6nGJ/hl7sS9MH4+lKjf/eKQFBn/0u7Dm07RyFRCxc2ui8H1CSXJk84fWcmEftuJlQ9BrGuG2BWXtlCBgRbzb0Fg/AP+3LHi5N9CrxsN1YWdxPj80k9omrlKA5pEO5iuEWIJDjuNRTZnniLV6NgaDAsJuekLy9CzburqpAIycI6EK86KDUHr1sqRMnqjNVwdjbZ8z8W8PYlwpi3skmY9mNyGyGJcdLKgeno5S9NMmbcNNWGixdf6AdEvNL/pnLf/JHnEiO0S2WvCf8zMC6PKC65cneMtNTHfBMAxryFzr1HGJ7h4bQoL/X5uor1gbh5UwBYntSaAgKwl7aRi8dbeJaNg4eN2PC0E5U= dmivlad@Ubuntu20"

#   }
# }

# // Создание ВМ во внутренней сети без публичного IP
# resource "yandex_compute_instance" "vm_privnet" {
#   name = "vm-from-private-net"
#   platform_id = "standard-v1"
#   resources {
#     cores         = 2
#     memory        = 2
#     core_fraction = 20
#   }

#   boot_disk {
#     initialize_params {
#       image_id = "fd8vljd295nqdaoogf3g"
#     }
#   }

#   network_interface {
#     subnet_id = yandex_vpc_subnet.private.id
#   }

#   metadata = {
#     serial-port-enable = 1
#     ssh-keys           = "ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9mi/8PO7m2/yrKy7ZnFr15bvdUrC6DUmqn/5DVKiHAO7hy9e9b+ktQ5WaejyCyrPr4pn474suPPLL2s6ZY71041pwKD2kQ1QeYNL0woHqOFCjlxeXpDAGVwUkwFekyUwCwmM1WWpZ9IqhPB50kN2FHnbzMONFti6nGJ/hl7sS9MH4+lKjf/eKQFBn/0u7Dm07RyFRCxc2ui8H1CSXJk84fWcmEftuJlQ9BrGuG2BWXtlCBgRbzb0Fg/AP+3LHi5N9CrxsN1YWdxPj80k9omrlKA5pEO5iuEWIJDjuNRTZnniLV6NgaDAsJuekLy9CzburqpAIycI6EK86KDUHr1sqRMnqjNVwdjbZ8z8W8PYlwpi3skmY9mNyGyGJcdLKgeno5S9NMmbcNNWGixdf6AdEvNL/pnLf/JHnEiO0S2WvCf8zMC6PKC65cneMtNTHfBMAxryFzr1HGJ7h4bQoL/X5uor1gbh5UwBYntSaAgKwl7aRi8dbeJaNg4eN2PC0E5U= dmivlad@Ubuntu20"

#   }
# }

# // Создание route table и статического маршрута для направления всего трафика из сети private на шлюз
# resource "yandex_vpc_route_table" "rt" {
#   name       = "netology-route-table"
#   network_id = yandex_vpc_network.netology.id

#   static_route {
#     destination_prefix = "0.0.0.0/0"
#     next_hop_address     = yandex_compute_instance.nat-gateway.network_interface.0.ip_address
#   }
# }