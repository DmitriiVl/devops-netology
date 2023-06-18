# Ответы на задания 05-virt-04-docker-compose   
## Задача 1  
Создайте собственный образ любой операционной системы (например ubuntu-20.04) с помощью Packer (инструкция).  
Чтобы получить зачёт, вам нужно предоставить скриншот страницы с созданным образом из личного кабинета YandexCloud.  
## Решение 1 
![YCIMG](img/yc-images.jpg)  
## Задача 2  
Создайте вашу первую виртуальную машину в YandexCloud с помощью web-интерфейса YandexCloud.
## Решение 2  
![YCVM](img/vm-yc-netology.jpg)  
## Задача 3  
С помощью Ansible и Docker Compose разверните на виртуальной машине из предыдущего задания систему мониторинга на основе Prometheus/Grafana. Используйте Ansible-код в директории (src/ansible).
Чтобы получить зачёт, вам нужно предоставить вывод команды "docker ps" , все контейнеры, описанные в docker-compose, должны быть в статусе "Up".
## Решение 3  
![DOCKERCPS](img/dockercomposeps.jpg)
## Задача 4  
1. Откройте веб-браузер, зайдите на страницу http://<внешний_ip_адрес_вашей_ВМ>:3000.
2. Используйте для авторизации логин и пароль из .env-file.
3. Изучите доступный интерфейс, найдите в интерфейсе автоматически созданные docker-compose-панели с графиками(dashboards).
4. Подождите 5-10 минут, чтобы система мониторинга успела накопить данные.
5. Чтобы получить зачёт, предоставьте:
скриншот работающего веб-интерфейса Grafana с текущими метриками, как на примере ниже.  
## Решение 4  
![GRAFANAMON](img/grafana-mon.jpg)

