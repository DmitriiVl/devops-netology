// Создание сетевого балансировщика  
resource "yandex_lb_network_load_balancer" "network-load-balancer" {
  name = "network-load-balancer"
  deletion_protection = "false"
  listener {
    name = "listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_compute_instance_group.ig-netology.load_balancer[0].target_group_id
    healthcheck {
      name = "healthchecker"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}