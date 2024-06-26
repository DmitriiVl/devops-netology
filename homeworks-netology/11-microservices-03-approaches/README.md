# Ответы на задания 11-microservices-03-approaches  

Вы работаете в крупной компании, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps-специалисту необходимо выдвинуть предложение по организации инфраструктуры для разработки и эксплуатации.


## Задача 1: Обеспечить разработку

Предложите решение для обеспечения процесса разработки: хранение исходного кода, непрерывная интеграция и непрерывная поставка. 
Решение может состоять из одного или нескольких программных продуктов и должно описывать способы и принципы их взаимодействия.

Решение должно соответствовать следующим требованиям:
- облачная система;
- система контроля версий Git;
- репозиторий на каждый сервис;
- запуск сборки по событию из системы контроля версий;
- запуск сборки по кнопке с указанием параметров;
- возможность привязать настройки к каждой сборке;
- возможность создания шаблонов для различных конфигураций сборок;
- возможность безопасного хранения секретных данных (пароли, ключи доступа);
- несколько конфигураций для сборки из одного репозитория;
- кастомные шаги при сборке;
- собственные докер-образы для сборки проектов;
- возможность развернуть агентов сборки на собственных серверах;
- возможность параллельного запуска нескольких сборок;
- возможность параллельного запуска тестов.

Обоснуйте свой выбор.

## Ответ к задаче 1  

Разумеется, при выборе конкретного инстумента для решения задачи всегда помним, что окончательное решение зависит от конкретной ситуации: размера проекта, бюджета, навыков и умений команды. Таким образом, для обеспечения процесса разработки можно как использовать несолько разных решений - внутренний GIT (с удивлением узнал, что и SVN еще поддерживается), Jenkins, Vault, локальный Docker Registry. Однако в целом, если хочется быстро получить полностью рабочий инструмент за умеренные  [деньги](https://about.gitlab.com/pricing/), а, возможно, на первых порах вообще бесплатно - GitLab Platform - универсальное, во всем мире понятное и удобное решение. Ну а по поводу локального Docker Registry все же придется озадачиться.  

## Задача 2: Логи

Предложите решение для обеспечения сбора и анализа логов сервисов в микросервисной архитектуре.
Решение может состоять из одного или нескольких программных продуктов и должно описывать способы и принципы их взаимодействия.

Решение должно соответствовать следующим требованиям:
- сбор логов в центральное хранилище со всех хостов, обслуживающих систему;
- минимальные требования к приложениям, сбор логов из stdout;
- гарантированная доставка логов до центрального хранилища;
- обеспечение поиска и фильтрации по записям логов;
- обеспечение пользовательского интерфейса с возможностью предоставления доступа разработчикам для поиска по записям логов;
- возможность дать ссылку на сохранённый поиск по записям логов.

Обоснуйте свой выбор.

## Ответ к задаче 2 

ELK - стандарт дефакто, особенно дискутировать тут смысла бы не видел. Решение состоит из следующих компонентов:

- Elasticsearch (хранение и поиск данных)
- Logstash (конвеер для обработки, фильтрации и нормализации логов)
- Kibana (интерфейс для удобного поиска и администрирования)

Закрывает абсолютное большинство задач, на рынке труда легко найти специалистов с соответствующими скилами, а значит - без поддержки не останитесь. 

## Задача 3: Мониторинг

Предложите решение для обеспечения сбора и анализа состояния хостов и сервисов в микросервисной архитектуре.
Решение может состоять из одного или нескольких программных продуктов и должно описывать способы и принципы их взаимодействия.

Решение должно соответствовать следующим требованиям:
- сбор метрик со всех хостов, обслуживающих систему;
- сбор метрик состояния ресурсов хостов: CPU, RAM, HDD, Network;
- сбор метрик потребляемых ресурсов для каждого сервиса: CPU, RAM, HDD, Network;
- сбор метрик, специфичных для каждого сервиса;
- пользовательский интерфейс с возможностью делать запросы и агрегировать информацию;
- пользовательский интерфейс с возможностью настраивать различные панели для отслеживания состояния системы.

Обоснуйте свой выбор.

## Ответ к задаче 3  

Существуют, конечно, вариации по выбору ПО для решения данного рода задач. Можно использовать, например, Zabbix для решениявышеописанных задач. Однако, последний, на мой взгляд более подойдет для решения задачи мониторинга ИТ-инфраструктуры на большом распределенном предприятии. Для решения вышеописанных задач все же более подходящим вариантом представяется следующая связка:  

- Основной компонент — Prometheus. Prometheus получает метрики из разных сервисов и собирает их в одном месте.
- Node exporter — небольшое приложение, собирающее метрики операционной системы и предоставляющее к ним доступ по HTTP. Prometheus собирает данные с одного или нескольких экземпляров Node Exporter.
- Grafana — это вишенка на торте. Grafana отображает данные из Prometheus в виде графиков и диаграмм, организованных в дашборды.

Это - проверенные временем и отлично кастомизируемые под различные задачи продукты, с поддержкой которых на современном рынке труда также не должно возникнуть вопросов.  