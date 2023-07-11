# Playbook description

Данные playbook устанавливает Clickhouse и Vector на два docker контейнера для хранения логов от Vector в Clickhouse database.

## GROUP VARS

___

### Clickhouse variables

#### __Installation__

| variable | описание |
|:---|:---|
| _clickhouse_version_ | определяет версию Clickhouse для установки.|
| _clickhouse_packages_ | список Clickhouse пакетов для скачивания |

### Vector variables

#### __Installation__

| variable | описание |
|:---|:---|
| _vector_version_ | определяет версию Vector. |
| _vector_package_ | имя пакета Vector. |
| _os_architecture_ | инструкция для задания версии ОС, куда производится установка. |

#### __Configuration__

| variable | описание |
|:---|:---|
| _vector_config_dir_ | директория по умолчанию для расположения конфигурационных файлов vector. |
| _vector_config_ | настройка подключения clickhouse and хранения данных. |

## Playbook tasks

___

### Clickhouse

__Clickhouse | Get distrib__ (Tag `get_clickhouse`) - скачивает пакеты clickhouse-server, clickhouse-client, clickhouse-common.\
__Clickhouse | Install packages__ (Tag `start_clickhouse`) - разворачивает Clickhouse.\
__Start clickhouse service__ - handler, которые стартует или перезапускает Clickhouse.

### Vector

__Vector | Install package__ (Tag `install_vector`) - создает директорию для пакета Vector.\
__Vector | Generate config__ (Tag `configure_vector`)- создает Vector .yml конфигурационный файл по пути /etc/vector из файла [vector.yml.j2](templates/vector.yml.j2) template.\
__Vector | Configure service__ (Tag `configure_vector`) - создает службу vector.service на основе 
[vector.service.j2](templates/vector.service.j2) template.\
__Start vector service__ - handler, которые стартует или перезапускает службу Vector.

___