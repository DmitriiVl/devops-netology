# Ответы на задания «Организация сети» 15.1-clopro-homeworks  

### Подготовка к выполнению задания

1. Домашнее задание состоит из обязательной части, которую нужно выполнить на провайдере Yandex Cloud, и дополнительной части в AWS (выполняется по желанию). 
2. Все домашние задания в блоке 15 связаны друг с другом и в конце представляют пример законченной инфраструктуры.  
3. Все задания нужно выполнить с помощью Terraform. Результатом выполненного домашнего задания будет код в репозитории. 
4. Перед началом работы настройте доступ к облачным ресурсам из Terraform, используя материалы прошлых лекций и домашнее задание по теме «Облачные провайдеры и синтаксис Terraform». Заранее выберите регион (в случае AWS) и зону.

---
### Задание 1. Yandex Cloud 

**Что нужно сделать**

1. Создать пустую VPC. Выбрать зону.
2. Публичная подсеть.

 - Создать в VPC subnet с названием public, сетью 192.168.10.0/24.
 - Создать в этой подсети NAT-инстанс, присвоив ему адрес 192.168.10.254. В качестве image_id использовать fd80mrhj8fl2oe87o4e1.
 - Создать в этой публичной подсети виртуалку с публичным IP, подключиться к ней и убедиться, что есть доступ к интернету.
3. Приватная подсеть.
 - Создать в VPC subnet с названием private, сетью 192.168.20.0/24.
 - Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс.
 - Создать в этой приватной подсети виртуалку с внутренним IP, подключиться к ней через виртуалку, созданную ранее, и убедиться, что есть доступ к интернету.

Resource Terraform для Yandex Cloud:

- [VPC subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet).
- [Route table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table).
- [Compute Instance](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance).

---

### Ответ к заданию    

Поднимаем всю инфраструктуру с помощью Terraform. Для этого создаем несколько файлов: манифес и файлы, содержащие переменные:  

- [Основной файл-манифест](infrastructure/main.tf)
- [Описание провайдеров](infrastructure/providers.tf)
- [Файл с переменными](infrastructure/variables.tf)
- [Описание security групп](infrastructure/security.tf)

Файлс personal.auto.tfvars не публикую. 

Для теста сначала применяем манифес с закомментированным кусов кода, описывающим создание route table:  

```bash
# resource "yandex_vpc_route_table" "rt" {
#   name       = "netology-route-table"
#   network_id = yandex_vpc_network.netology.id

#   static_route {
#     destination_prefix = "0.0.0.0/0"
#     next_hop_address     = yandex_compute_instance.nat-gateway.network_interface.0.ip_address
#   }
# }
```

Также комментируем ссылку на route table в следующем кусе кода:  

```bash
resource "yandex_vpc_subnet" "private" {
  name           = var.vpc_name_private
  zone           = var.default_zone
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = var.default_cidr_private
#   route_table_id = yandex_vpc_route_table.rt.id
}
```

Подключаемся к ВМ из будличной подсети, проверяем интернет, все работает:  

```bash
ubuntu@fhmksgkqo1kp84mb0t39:~$ ping ya.ru
PING ya.ru (5.255.255.242) 56(84) bytes of data.
64 bytes from ya.ru (5.255.255.242): icmp_seq=1 ttl=56 time=0.766 ms
64 bytes from ya.ru (5.255.255.242): icmp_seq=2 ttl=56 time=0.435 ms
64 bytes from ya.ru (5.255.255.242): icmp_seq=3 ttl=56 time=0.361 ms
--- ya.ru ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 0.361/0.520/0.766/0.176 ms

```

Далее подключаемся к приветной машине, используя публичную в качесте hope-хоста. Для этого копируем соответствующий приветный ключ командой c хост машины:  

```bash
scp -i ~/.ssh/id_rsa.new /home/dmivlad/.ssh/id_rsa.new  ubuntu@51.250.10.144:.ssh/id_rsa

```

После копирования ключа подключение с публичной ВМ на приватную происходит успешно:  

```bash
ubuntu@fhmksgkqo1kp84mb0t39:~$ ssh ubuntu@192.168.20.22
The authenticity of host '192.168.20.22 (192.168.20.22)' can't be established.
ED25519 key fingerprint is SHA256:q/lfH+2zXSRJ5EIVhoNKF6hHpo5tA995urLUvEGEvAU.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.20.22' (ED25519) to the list of known hosts.
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-91-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sat Jan 27 08:28:15 PM UTC 2024

  System load:  0.09912109375     Processes:             135
  Usage of /:   53.7% of 7.79GB   Users logged in:       0
  Memory usage: 10%               IPv4 address for eth0: 192.168.20.22
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

```

Проверяем доступность публиной ВМ и возможность выхода в Интернет:  

```bash
ubuntu@fhmnniei6gg18hc454ud:~$ ping 192.168.10.10
PING 192.168.10.10 (192.168.10.10) 56(84) bytes of data.
64 bytes from 192.168.10.10: icmp_seq=1 ttl=61 time=6.05 ms
64 bytes from 192.168.10.10: icmp_seq=2 ttl=61 time=0.595 ms
64 bytes from 192.168.10.10: icmp_seq=3 ttl=61 time=0.723 ms
--- 192.168.10.10 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2007ms
rtt min/avg/max/mdev = 0.595/2.456/6.051/2.542 ms
ubuntu@fhmnniei6gg18hc454ud:~$ ping ya.ru
PING ya.ru (5.255.255.242) 56(84) bytes of data.
--- ya.ru ping statistics ---
10 packets transmitted, 0 received, 100% packet loss, time 9208ms

```

Можем видеть, что публичная ВМ с приветной доступна, в Интернет выхода нет. Раскомментируем ранее закомментированные части кода, касающиеся route table, переприменяем, получаем следующий результат:  

```bash
ubuntu@fhmnniei6gg18hc454ud:~$ ping ya.ru
PING ya.ru (77.88.55.242) 56(84) bytes of data.
64 bytes from ya.ru (77.88.55.242): icmp_seq=1 ttl=52 time=5.31 ms
64 bytes from ya.ru (77.88.55.242): icmp_seq=2 ttl=52 time=4.12 ms
64 bytes from ya.ru (77.88.55.242): icmp_seq=3 ttl=52 time=4.23 ms
64 bytes from ya.ru (77.88.55.242): icmp_seq=4 ttl=52 time=4.06 ms
64 bytes from ya.ru (77.88.55.242): icmp_seq=5 ttl=52 time=4.06 ms
--- ya.ru ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4006ms
rtt min/avg/max/mdev = 4.055/4.353/5.310/0.482 ms

```

Интернет с приватной ВМ доступен через NAT gateway. Что и требвоалось продемонстрировать. В GUI созданные ВМ выглядят следующим образом:  

![GUIVM](assets/guivm.jpg)  
