# Ответы на задания 10-monitoring-01-base

### Задания  

1. Вас пригласили настроить мониторинг на проект. На онбординге вам рассказали, что проект представляет из себя платформу для вычислений с выдачей текстовых отчётов, которые сохраняются на диск. 
Взаимодействие с платформой осуществляется по протоколу http. Также вам отметили, что вычисления загружают ЦПУ. Какой минимальный набор метрик вы выведите в мониторинг и почему?

2. Менеджер продукта, посмотрев на ваши метрики, сказал, что ему непонятно, что такое RAM/inodes/CPUla. Также он сказал, что хочет понимать, насколько мы выполняем свои обязанности перед клиентами и какое качество обслуживания. Что вы можете ему предложить?

3. Вашей DevOps-команде в этом году не выделили финансирование на построение системы сбора логов. Разработчики, в свою очередь, хотят видеть все ошибки, которые выдают их приложения. Какое решение вы можете предпринять в этой ситуации, чтобы разработчики получали ошибки приложения?

4. Вы, как опытный SRE, сделали мониторинг, куда вывели отображения выполнения SLA = 99% по http-кодам ответов. 
Этот параметр вычисляется по формуле: summ_2xx_requests/summ_all_requests. Он не поднимается выше 70%, но при этом в вашей системе нет кодов ответа 5xx и 4xx. Где у вас ошибка?
_____

### Решения  

1. Для реализации системы мониторинга в рамках поставленной задачи предложил бы контролировать следующие метрики:  

Мониторинг оборудования:  
- CPU LA: позволит контролировать загрузку CPU, настравать соответствующие триггеры для оптимизации обслуживания.
- RAM/SWAP: позволит контролировать утилизацию оперативной памяти и файла подкачки.
- NET: позволит контролировать нагрузку на сетевые интерфейсы, оценивать доступность по сетевым протоколам.
- FS: позволит контролировать состояние файловой системы - нагрузку на нее и объем свободного места.
- IOPS: позволит контролировать состояние дисков и RAID массивов, количество операций ввода/вывода.

Мониторинг приложения:  
- Количество текстовых отчетов, которое генерирует приложения в рамках своей бизнес-логики.
- Количество ответов веб-сервера: 200-х в случае необходимости мониторинга успешного ответа или 400-х и 500-х в случае, если нужно контролировать ошибки.

2. Касательно метрик RAM и CPULA - постарался дать их описание в предыдущем задании. Касательно метрики INODES, которую я, вероятно должен был указать, но забыл можно сказать, что в силу того, что количество INODES в файловой системе ограничено и в случае переполнения может привести к отказу в работоспособности приложения - данную метрику также имеет смысл контролировать.  

Что же относительно взаимоотношений с клиентами - в контракте на разработку/поддержку продукта необходимо зафиксировать SLA. После этого необходимо установить SLO. Все эти действия позволят настроить SLI и предоставлять заказчику метрики для контроля за нужный период времени или в режиме реального времени, оценки качества обслуживания и минимизировать разногласия с ним в будущем.  

3. Для решения задачи приходит на ум два варианта:  
- Использовать в качестве системы сбора логов, например Zabbix, он это умеет, процесс настройки описан на данной [странице](https://www.zabbix.com/documentation/current/en/manual/config/items/itemtypes/log_items).
- Написать свой скрипт, которые будет парсить логи. Можно в том числе реализовать визуализацию, например, средствами MS BI.

4. Проблема изначального подхода заключается в том, что он не учитывает ответы сервера, отличные от 200-х, при этом не являющимися ответами, фиксирующими ошибки на стороне веб-сервера. Речь об информационных запросах и редиректах.

Правильный подхода следующий:  

```
summ_1xx_requests+summ_2xx_requests+summ_3xx_requests/summ_all_requests
```
