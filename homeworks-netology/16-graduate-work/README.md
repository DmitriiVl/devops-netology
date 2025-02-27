# Дипломная работа выпускника курса "Devops-инженер" Владимирова Дмитрия  

### Задание

Задание доступно по [ссылке](https://github.com/netology-code/devops-diplom-yandexcloud). Основные вехи выполнения работы следующие:  

- Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
- Запустить и сконфигурировать Kubernetes кластер.
- Установить и настроить систему мониторинга.
- Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
- Настроить CI для автоматической сборки и тестирования.
- Настроить CD для автоматического развёртывания приложения.

### Часть нулевая. Создание s3 бакета для хранения конфигурации

В первую очередь возникла необходимость обновить Terraform на виртуальной машине до актуальной версии. Бинарник был скачан с официального [ресурса](https://developer.hashicorp.com/terraform/install).  


Для успешной инициализации проекта выполняем команду *export TF_CLI_CONFIG_FILE=/home/dmivlad/Diplom/Zero\ part/infrastructure/.terraformrc*, создаем сам файл .terraformrc следующего содержания:  

```bash
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
```

далее *terraform init*.

Использовались конфигурационные файлы из папки [Zero part](Zero%20part/infrastructure/) для создания сервисного аккаунта и бакета для удаленного хранения конфигурации. 

### Часть первая. Создание vpc и подсетей в разных зонах доступности, разворачивание K8S кластера

Для реализации поставленных задач по созданию vpc и подсетей в разных зонах доступности использовались конфигурационные файлы из папки [First part](First%20part/infrastructure/). Для обеспечения удаленного хранения файла-состояния инфраструктуры в terraform необходимо изменить файл *providers.tf* и привести его к следующему виду:  

```bash
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
  access_key = "YCAJ..."
  secret_key = "YCNd..."

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
```

Значения *access_key* и *secret_key* были получены после создания в предыдущем блоке s3 быкета. Сами значени могут быть получены с использованием команд:  

```bash
terraform output secret_key
terraform output access_key
```

Запускаем *terraform apply* для создания vpc с подсетями. Проверяем, что terraform.tfstate пишется в Object storage:  

![BUK](First%20part/infrastructure/bucket-img.jpg)  

Далее создаем манифест для виртуальных машин. В нашем сценарии будет одна мастер-нода и две воркер-ноды:  

```bash
// Создание Мастер-ноду 
resource "yandex_compute_instance" "master-node-k8s" {
  name = "master-node-k8s"
  zone = var.cloud_yandex_zoned
  platform_id = "standard-v3"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ba9d5mfvlncknt2kd"
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
    ssh-keys           = "ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9mi/8PO7m2/yrKy7ZnFr15bvdUrC6DUmqn/5DVKiHAO7hy9e9b+ktQ5WaejyCyrPr4pn474suPPLL2s6ZY71041pwKD2kQ1QeYNL0woHqOFCjlxeXpDAGVwUkwFekyUwCwmM1WWpZ9IqhPB50kN2FHnbzMONFti6nGJ/hl7sS9MH4+lKjf/eKQFBn/0u7Dm07RyFRCxc2ui8H1CSXJk84fWcmEftuJlQ9BrGuG2BWXtlCBgRbzb0Fg/AP+3LHi5N9CrxsN1YWdxPj80k9omrlKA5pEO5iuEWIJDjuNRTZnniLV6NgaDAsJuekLy9CzburqpAIycI6EK86KDUHr1sqRMnqjNVwdjbZ8z8W8PYlwpi3skmY9mNyGyGJcdLKgeno5S9NMmbcNNWGixdf6AdEvNL/pnLf/JHnEiO0S2WvCf8zMC6PKC65cneMtNTHfBMAxryFzr1HGJ7h4bQoL/X5uor1gbh5UwBYntSaAgKwl7aRi8dbeJaNg4eN2PC0E5U= dmivlad@Ubuntu20"

  }
}

// Создание две одинаковые Воркер-ноды  
resource "yandex_compute_instance" "worker-node-k8s" {
  name = "worker-node-k8s-${count.index + 1}"
  zone = var.cloud_yandex_zoned
  count = 2
  platform_id = "standard-v3"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ba9d5mfvlncknt2kd"
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
    ssh-keys           = "ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9mi/8PO7m2/yrKy7ZnFr15bvdUrC6DUmqn/5DVKiHAO7hy9e9b+ktQ5WaejyCyrPr4pn474suPPLL2s6ZY71041pwKD2kQ1QeYNL0woHqOFCjlxeXpDAGVwUkwFekyUwCwmM1WWpZ9IqhPB50kN2FHnbzMONFti6nGJ/hl7sS9MH4+lKjf/eKQFBn/0u7Dm07RyFRCxc2ui8H1CSXJk84fWcmEftuJlQ9BrGuG2BWXtlCBgRbzb0Fg/AP+3LHi5N9CrxsN1YWdxPj80k9omrlKA5pEO5iuEWIJDjuNRTZnniLV6NgaDAsJuekLy9CzburqpAIycI6EK86KDUHr1sqRMnqjNVwdjbZ8z8W8PYlwpi3skmY9mNyGyGJcdLKgeno5S9NMmbcNNWGixdf6AdEvNL/pnLf/JHnEiO0S2WvCf8zMC6PKC65cneMtNTHfBMAxryFzr1HGJ7h4bQoL/X5uor1gbh5UwBYntSaAgKwl7aRi8dbeJaNg4eN2PC0E5U= dmivlad@Ubuntu20"

  }
}
```

Применяем манифест: сети и подсети созданы, виртуалки в необходимых зонах доступности запущены, демонстрация на скриншоте:  

![VIRT](First%20part/infrastructure/vms-img.jpg)  

Далее готовимся к установке на поднятой инфраструктуре кластера K8S. Будем использовать [Kubespray](https://github.com/kubernetes-sigs/kubespray/tree/master). Будем использовать проверенный release-2.20. Таким образом, скачиваем репозиторий и переходим в соответствующую ветку:  

```bash
git clone https://github.com/kubernetes-sigs/kubespray.git
git checkout release-2.20
```

Также для установки необходим Python, проверяем его наличие:  

```bash
dmivlad@Ubuntu20:~/Diplom/Dist/kubespray$ python3 --version
Python 3.8.10
```  

Далее правим inventory файл *Kubespray*, внося в него данные своих хостов из Яндекс облака, в файле *cluster.yml* устанавливаем использование сетевого плагина flannel, вместо выбранного по умолчанию calico и, а также устанавливаем, находясь в корне репозитория, необходимые для работы *Kubespray* зависимости командой:  

```bash
sudo pip3 install -r requirements.txt
```
Далее стартуем установку самого *Kubespray*:  

```bash
ansible-playbook -i /home/dmivlad/Diplom/Dist/kubespray/inventory/dmivlad-k8s-cluster/inventory.ini --become --become-user=root /home/dmivlad/Diplom/Dist/kubespray/cluster.yml -u ubuntu
```

Инсталляция завершается успешно, о чем свидетельствует успешно отработавший playbook:  

```bash
RUNNING HANDLER [kubernetes/preinstall : Preinstall | Restart systemd-resolved] ***
changed: [worker-node-k8s-1]
changed: [master-node-k8s]
changed: [worker-node-k8s-2]
Пятница 15 марта 2024  20:55:28 +0300 (0:00:03.380)       0:14:46.540 ********* 
Пятница 15 марта 2024  20:55:28 +0300 (0:00:00.051)       0:14:46.592 ********* 
Пятница 15 марта 2024  20:55:28 +0300 (0:00:00.048)       0:14:46.640 ********* 
Пятница 15 марта 2024  20:55:28 +0300 (0:00:00.050)       0:14:46.690 ********* 
Пятница 15 марта 2024  20:55:28 +0300 (0:00:00.044)       0:14:46.735 ********* 
Пятница 15 марта 2024  20:55:28 +0300 (0:00:00.092)       0:14:46.827 ********* 
Пятница 15 марта 2024  20:55:28 +0300 (0:00:00.034)       0:14:46.862 ********* 
Пятница 15 марта 2024  20:55:28 +0300 (0:00:00.044)       0:14:46.906 ********* 
Пятница 15 марта 2024  20:55:28 +0300 (0:00:00.065)       0:14:46.972 ********* 

PLAY RECAP *********************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
master-node-k8s            : ok=672  changed=137  unreachable=0    failed=0    skipped=1176 rescued=0    ignored=5   
worker-node-k8s-1          : ok=536  changed=110  unreachable=0    failed=0    skipped=722  rescued=0    ignored=2   
worker-node-k8s-2          : ok=536  changed=110  unreachable=0    failed=0    skipped=721  rescued=0    ignored=2   

Пятница 15 марта 2024  20:55:28 +0300 (0:00:00.122)       0:14:47.094 ********* 
=============================================================================== 
kubernetes/kubeadm : Join to cluster ----------------------------------- 38.49s
kubernetes/control-plane : kubeadm | Initialize first master ----------- 37.82s
kubernetes/preinstall : Install packages requirements ------------------ 26.68s
etcd : reload etcd ----------------------------------------------------- 21.12s
etcd : Gen_certs | Write etcd member/admin and kube_control_plane clinet certs to other etcd nodes -- 18.95s
etcd : Gen_certs | Write etcd member/admin and kube_control_plane clinet certs to other etcd nodes -- 18.10s
kubernetes-apps/ansible : Kubernetes Apps | Start Resources ------------ 15.74s
download : download_container | Download image if required ------------- 15.33s
download : download_container | Download image if required ------------- 13.49s
download : download_container | Download image if required ------------- 12.11s
kubernetes-apps/ansible : Kubernetes Apps | Lay Down CoreDNS templates -- 11.97s
download : download_container | Download image if required ------------- 11.01s
download : download_container | Download image if required -------------- 9.78s
kubernetes-apps/network_plugin/flannel : Flannel | Wait for flannel subnet.env file presence --- 9.76s
network_plugin/cni : CNI | Copy cni plugins ----------------------------- 8.13s
download : download_container | Download image if required -------------- 7.98s
etcd : Gen_certs | Write node certs to other etcd nodes ----------------- 7.55s
etcd : Gen_certs | Write node certs to other etcd nodes ----------------- 7.33s
container-engine/containerd : containerd | Unpack containerd archive ---- 7.03s
kubernetes/preinstall : Preinstall | wait for the apiserver to be running --- 6.86s
```

Выводим список работающих подов с мастер-ноды, видим, что команда отрабатывает без ошибок:  

```bash
ubuntu@master-node-k8s:~$ sudo kubectl get pods --all-namespaces
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
kube-system   coredns-74d6c5659f-bgm8z                  1/1     Running   0          26m
kube-system   coredns-74d6c5659f-pq4xc                  1/1     Running   0          26m
kube-system   dns-autoscaler-59b8867c86-2dg2t           1/1     Running   0          26m
kube-system   kube-apiserver-master-node-k8s            1/1     Running   1          29m
kube-system   kube-controller-manager-master-node-k8s   1/1     Running   1          29m
kube-system   kube-flannel-csq9g                        1/1     Running   0          27m
kube-system   kube-flannel-hq7hw                        1/1     Running   0          27m
kube-system   kube-flannel-rp9f9                        1/1     Running   0          27m
kube-system   kube-proxy-6gj9m                          1/1     Running   0          27m
kube-system   kube-proxy-hllb2                          1/1     Running   0          27m
kube-system   kube-proxy-q5m92                          1/1     Running   0          27m
kube-system   kube-scheduler-master-node-k8s            1/1     Running   1          29m
kube-system   nginx-proxy-worker-node-k8s-1             1/1     Running   0          27m
kube-system   nginx-proxy-worker-node-k8s-2             1/1     Running   0          27m
kube-system   nodelocaldns-2s2hm                        1/1     Running   0          26m
kube-system   nodelocaldns-4n82f                        1/1     Running   0          26m
kube-system   nodelocaldns-mfmjb                        1/1     Running   0          26m
```

### Часть вторая. Создание репозитория, Dockerfile, nginx config file  

Готовим конфигурационный файл nginx и Dockerfile, все файлы доступны [по ссылке](Second%20part/)

Скачиваем Docker image командой и проверяем наличие образа:  

```bash
sudo docker pull nginx:1.24
sudo docker image list
```

Создаем папку *html* и переносим в нее ранее созданный индексный файл *index.html*:  

```bash
mkdir html
mv index.html html/
```

Создаем Dockerfile следующего содержания:  

```dockerfile
FROM nginx:1.24
COPY html /usr/share/nginx/html
```

На основании данного файла собираем образ приложения *app-k8s-graduate-work*:  

```bash
dmivlad@Ubuntu20:~/Diplom/Second part$ sudo docker build -t milvo/app-k8s-graduate-work:0.1 .
[+] Building 0.2s (7/7) FINISHED                                                                                      
 => [internal] load build definition from Dockerfile                                                             0.1s
 => => transferring dockerfile: 87B                                                                              0.0s
 => [internal] load .dockerignore                                                                                0.1s
 => => transferring context: 2B                                                                                  0.0s
 => [internal] load metadata for docker.io/library/nginx:1.24                                                    0.0s
 => [internal] load build context                                                                                0.0s
 => => transferring context: 61B                                                                                 0.0s
 => [1/2] FROM docker.io/library/nginx:1.24                                                                      0.0s
 => CACHED [2/2] COPY html /usr/share/nginx/html                                                                 0.0s
 => exporting to image                                                                                           0.0s
 => => exporting layers                                                                                          0.0s
 => => writing image sha256:d014320bc5c600ecc4a201db119845ec0106118143b96f1454ea1f5b93bd4e6e                     0.0s
 => => naming to docker.io/library/app-k8s-graduate-work:0.1                                                     0.0s
dmivlad@Ubuntu20:~/Diplom/Second part$ sudo docker images
REPOSITORY              TAG          IMAGE ID       CREATED          SIZE
app-k8s-graduate-work   0.1          d014320bc5c6   29 minutes ago   142MB
python                  3.9-alpine   6946662f018b   6 months ago     47.8MB
nginx                   1.24         fea54fd2dc99   11 months ago    142MB
elastic/filebeat        8.7.0        b30b6dee943c   11 months ago    291MB
```

Запускаем и проверяем отображение веб-страницы:  

```bash
sudo docker run -d --name app-k8s-graduate-work -p 80:80 app-k8s-graduate-work
```

![PAGE](Second%20part/opened-web-page.jpg)

Пушим в Registry DockerHub во вновь созданный репозиторий:  

```bash
sudo docker push milvo/app-k8s-graduate-work:0.1
```

![IMGREG](Second%20part/imgreg.jpg)

Скачать образ из репозитория можно по [ссылке](https://hub.docker.com/repository/docker/milvo/app-k8s-graduate-work/general)

### Часть третья. Установка системы мониторинга kube-prometheus и деплой приложения

Согласно инструкции на сайте разработчика выполняем следующие команды для установки kube-prometheus и переходим в ветку с поддерживаемой нашим кластером версии:  

```bash
git clone git@github.com:prometheus-operator/kube-prometheus.git
cd kube-prometheus
git checkout release-0.12
kubectl apply --server-side -f manifests/setup
kubectl wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring
kubectl apply -f manifests/
```

ВАЖНО! Для обеспечения возможности подключения к кластеру с хост-машины, необходимо внести изменения в файл *vi /home/dmivlad/Diplom/Dist/kubespray/inventory/dmivlad-k8s-cluster/group_vars/k8s_cluster/k8s-cluster.yml* в параметр *supplementary_addresses_in_ssl_keys: [тут должен быть ip адрес ноды в Yandex Cloud для подключения]*. Снова запускаем playbook c Kubespray для обновления параметров доступа. После проделанных операция копируем конфиг файл Kubernetes с мастер-ноды (в нашей случае master-node-k8s) *~/.kube/config* на хост машину и запускаем команду:  

```bash
kubectl config use-context kubernetes-admin@cluster.local
dmivlad@Ubuntu-Kuber:~/.kube$ kubectl get nodes
NAME                STATUS   ROLES           AGE   VERSION
master-node-k8s     Ready    control-plane   9h    v1.24.6
worker-node-k8s-1   Ready    <none>          9h    v1.24.6
worker-node-k8s-2   Ready    <none>          9h    v1.24.6
dmivlad@Ubuntu-Kuber:~/.kube$ kubectl -n monitoring port-forward svc/grafana 3000
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
```

Проверяем работоспособность веб-интерфейса Grafana, убеждаемся, что все работает:  

![GRAFAN](Third%20part/grafana.jpg)  

Далее пишем манифест для Deployment и Service для запуска приложения. Все конфигурационные файлы размещены в соответствующей [папке](Third%20part/).  

Создаем необходимый namespace, запускаем файл-манифест, убеждаемся, что поды и сервис поднялись:  

```bash
ubuntu@master-node-k8s:~$ sudo kubectl create ns ns-graduate-work
ubuntu@master-node-k8s:~$ sudo kubectl apply -f app-k8s-graduate-work.yml 
deployment.apps/app-k8s-graduate-work unchanged
service/svc-k8s-graduate-work unchanged
ubuntu@master-node-k8s:~$ sudo kubectl get pods
NAME                                     READY   STATUS    RESTARTS   AGE
app-k8s-graduate-work-7449f566dd-4fgcl   1/1     Running   0          3m34s
app-k8s-graduate-work-7449f566dd-7p7gl   1/1     Running   0          3m34s
app-k8s-graduate-work-7449f566dd-dxmx9   1/1     Running   0          3m34s
ubuntu@master-node-k8s:~$ sudo kubectl get svc
NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
svc-k8s-graduate-work   ClusterIP   10.233.53.247   <none>        8081/TCP   3m37s
```

Пробрасываем порт и проверяем доступность приложения через веб-интерфейс:  

```bash
dmivlad@Ubuntu-Kuber:~$ kubectl -ns-graduate-work port-forward svc/svc-k8s-graduate-work 8081
Forwarding from 127.0.0.1:8081 -> 80
Forwarding from [::1]:8081 -> 80
Handling connection for 8081
```

![APPWEB](Third%20part/appweb.jpg)  

### Часть четвертая. CI/CD и деплой приложения  

В качестве инструмента для CI/CD был выбран встроенный в GitHub функционал - *GitHub Actions*. В репозитории с [приложением](https://github.com/DmitriiVl/app-k8s-graduate-work) были добавлены следующие переменные (секреты):  

- DOCKERHUB_TOKEN - переменная для хранения значения токена для подключения к DockerHub.
- DOCKERHUB_USERNAME - переменная для хранения значения имени пользователя для подключения к DockerHub.
- DOCKER_REPO_NAME - переменная для хранения значения имени DockerHub репозитория.
- KUBE_CONFIG - переменная, хранящая строковое значение файла kubeconfig, зашифрованного в base64.  

Далее в формале YAML был описан манифест, доступный по [ссылке](Fourth%20part/github_actions_graduate_k8s.yml). В данном манифесте описыаются действия, необходимые для сборки и деплоя приложения, в частности:  

- скачивания данных с репозитория и запуск сборки Docker файла.
- назначение тегов сборкам.
- push собранных файлов в DockerHub с назначенными тегами.  
- создание файла kubeconfig из расшифрованной переменной KUBE_CONFIG.
- переключение на необходимый K8S контекст и запуск авто-деплоя приложения с тегом latest в развернутый кластер. 

Перед запуском манифеста получаем значение для записи в переменную KUBE_CONFIG:  

```bash
dmivlad@Ubuntu-Kuber:~$ cat config | base64
```

Скриншот успешно отработавшего манифеста GitHub Actions прилагается:  

![CICD](Fourth%20part/CICD.jpg)   

Также прилагаю данные успешного развертывания K8S манифеста:  

```bash
ubuntu@master-node-k8s:~$ sudo kubectl get deployment -n ns-graduate-work
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
app-k8s-graduate-work   3/3     3            3           3h7m
ubuntu@master-node-k8s:~$ sudo kubectl get svc -n ns-graduate-work
NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
svc-k8s-graduate-work   ClusterIP   10.233.52.164   <none>        8081/TCP   3h7m
ubuntu@master-node-k8s:~$ sudo kubectl get pods -n ns-graduate-work
NAME                                     READY   STATUS    RESTARTS   AGE
app-k8s-graduate-work-5867864cbd-bwxfr   1/1     Running   0          3h7m
app-k8s-graduate-work-5867864cbd-p2c4n   1/1     Running   0          3h7m
app-k8s-graduate-work-5867864cbd-s67sp   1/1     Running   0          3h7m
```




