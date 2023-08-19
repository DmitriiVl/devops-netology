# Ответы на задания 10-monitoring-03-grafana  

### Задание 1

1. Используя директорию [help](./help) внутри этого домашнего задания, запустите связку prometheus-grafana.
1. Зайдите в веб-интерфейс grafana, используя авторизационные данные, указанные в манифесте docker-compose.
1. Подключите поднятый вами prometheus, как источник данных.
1. Решение домашнего задания — скриншот веб-интерфейса grafana со списком подключенных Datasource.

### Решение 1 
Задание выполнено: манифест развернут, скриншот веб-интерфейса Grafana со списком подключенных Datasource ниже:  
![GRAFANASOURCES](assets/grafanasources.jpg) 

## Задание 2

Изучите самостоятельно ресурсы:

1. [PromQL tutorial for beginners and humans](https://valyala.medium.com/promql-tutorial-for-beginners-9ab455142085).
1. [Understanding Machine CPU usage](https://www.robustperception.io/understanding-machine-cpu-usage).
1. [Introduction to PromQL, the Prometheus query language](https://grafana.com/blog/2020/02/04/introduction-to-promql-the-prometheus-query-language/).

Создайте Dashboard и в ней создайте Panels:

- утилизация CPU для nodeexporter (в процентах, 100-idle);
- CPULA 1/5/15;
- количество свободной оперативной памяти;
- количество места на файловой системе.

Для решения этого задания приведите promql-запросы для выдачи этих метрик, а также скриншот получившейся Dashboard.

### Решение 2  

PROMQL- запросы выглядят следующим образом:  

утилизация CPU для nodeexporter  
```
100 - ((irate(node_cpu_seconds_total{job="nodeexporter",mode="idle"}[5m])) * 100)
```

CPULA 1/5/15  
```
node_load1
node_load5
node_load15
```  

количество свободной оперативной памяти  
```
node_memory_MemFree_bytes 
node_memory_MemTotal_bytes
```  

количество места на файловой системе  
```
node_filesystem_avail_bytes{mountpoint="/"}
```

Вкриншот получившейся Dashboard:  
![GRAFANABOARDF](assets/grafanaboardf.jpg) 


## Задание 3

1. Создайте для каждой Dashboard подходящее правило alert — можно обратиться к первой лекции в блоке «Мониторинг».
1. В качестве решения задания приведите скриншот вашей итоговой Dashboard.

### Решение 3  

В предложенной версии манифест файла в версии Grafana не доступен полный блок меню Alert. Обновил в контейнере на версию latest.  

Настроен Alert на использование оперативной памяти, по подобию примера из лекции. Скриншот ниже:  

![GRAFANAALERT](assets/grafanaalert.jpg) 


## Задание 4

1. Сохраните ваш Dashboard.Для этого перейдите в настройки Dashboard, выберите в боковом меню «JSON MODEL». Далее скопируйте отображаемое json-содержимое в отдельный файл и сохраните его.
1. В качестве решения задания приведите листинг этого файла.

### Решение 4  
Файл выгружен, его можно скачать по ссылке [grafana-netology.json](assets/grafana-netology.json)  
