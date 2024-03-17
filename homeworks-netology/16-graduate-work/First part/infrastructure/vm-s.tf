// Создание Мастер-ноду 
resource "yandex_compute_instance" "master-node-k8s" {
  name = "master-node-k8s"
  allow_stopping_for_update = true
  zone = var.cloud_yandex_zoned
  platform_id = "standard-v3"
  resources {
    cores         = 4
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kp2cfs7pc786lfv2t"
      size = "30"     
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGaPevtW3iWSSoAaWSxIqsOIyz5nQFGfD2gZiHcW46SrbUP2rJD27br3wEim00F0guBHR77/1G0huhD+fWMpjqKLmkhl/QAXQx+13KjkFIsQ4gpZjdH14pg2T65ELcHJIkjDDyEkUPzYGaZR6Mgb8LNYnc0sewZOsEZRxlqFafpORaUiqqRNwouBMhDx0O2EHGghGeEoATde7oJvC9gbCouDz8ZguIDKnHsigmf5o9JZMkp/0wlDjFVEU/saHR54Dzx8kIwtSDJs2O6bm142GYvbwxCcreMWbEAwtTlr8NqfvFyEULNYz2/b+zqSJgC3Dt11/j+ZebgCGa51GLq7XPINU1PqW4hAspnzPRIxk6GdcCKRpT8jUIBK09+eug6uMgXlt33YRDfRNt+K6UhJ/aQuAkVIrsuA1+LBnrCw7+bgg+q0uBoXTG6xUZZZDV5PmTRuKmPaOhtEzJzq42HaIe8XKIJwY7QsoLg553UgvEEb3zoG0w9WecP1Kulm8ANoM= root@Ubuntu20"

  }
}

// Создание две одинаковые Воркер-ноды  
resource "yandex_compute_instance" "worker-node-k8s" {
  name = "worker-node-k8s-${count.index + 1}"
  allow_stopping_for_update = true
  zone = var.cloud_yandex_zoned
  count = 2
  platform_id = "standard-v3"
  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kp2cfs7pc786lfv2t"
      size = "30"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGaPevtW3iWSSoAaWSxIqsOIyz5nQFGfD2gZiHcW46SrbUP2rJD27br3wEim00F0guBHR77/1G0huhD+fWMpjqKLmkhl/QAXQx+13KjkFIsQ4gpZjdH14pg2T65ELcHJIkjDDyEkUPzYGaZR6Mgb8LNYnc0sewZOsEZRxlqFafpORaUiqqRNwouBMhDx0O2EHGghGeEoATde7oJvC9gbCouDz8ZguIDKnHsigmf5o9JZMkp/0wlDjFVEU/saHR54Dzx8kIwtSDJs2O6bm142GYvbwxCcreMWbEAwtTlr8NqfvFyEULNYz2/b+zqSJgC3Dt11/j+ZebgCGa51GLq7XPINU1PqW4hAspnzPRIxk6GdcCKRpT8jUIBK09+eug6uMgXlt33YRDfRNt+K6UhJ/aQuAkVIrsuA1+LBnrCw7+bgg+q0uBoXTG6xUZZZDV5PmTRuKmPaOhtEzJzq42HaIe8XKIJwY7QsoLg553UgvEEb3zoG0w9WecP1Kulm8ANoM= root@Ubuntu20"

  }
}