
# Playbook description

Данные playbook устанавливает Clickhouse и Vector на два docker контейнера для хранения логов от Vector в Clickhouse database. Также playbook устанавливает и настраивает Lighthouse на третьем сервере.

## GROUP VARS

___

### All

| variable | описание |
|:---|:---|
| _ssh_port_ | ssh удаленного хоста |
| _ssh_pkey_file_ | путь до файла ssh privatekey |
| _sudo_user_ | имя пользователя для подлкючения по ssh к удаленному серверу |
| _sudo_pass_ | пароль пользователя сервера |

### Clickhouse variables

#### __Installation__

| variable | описание |
|:---|:---|
| _clickhouse_version_ | определяет версию Clickhouse для установки. |
| _clickhouse_packages_ | список Clickhouse пакетов для скачивания. |

#### __Server configuration__

| variable | описание |
|:---|:---|
| _clickhouse_http_port_ | http порт (по умолчанию 8123). |
| _clickhouse_tcp_port_ | tcp порт (по умолчанию 9000). |
| _clickhouse_interserver_http_ | Порт для взаимодействия серверов (по умолчанию 9009). |
| _clickhouse_listen_host_ | адреса хостов, которые необходимо слушать. |
| _clickhouse_path_configdir_ | путь по умолчанию для директории с конфигурацией. |
| _clickhouse_path_user_files_ | путь для пользовательских файлов конфигурации. |
| _clickhouse_path_data_ | руть к библиотекам clickhouse. |
| _clickhouse_path_tmp_ | директория для временных файлов. |
| _clickhouse_path_logdir_ | директория для log файлов. |
| _clickhouse_service_ | имя clickhouse service. |

#### __User configuration__

| variable | описание |
|:---|:---|
| _clickhouse_networks_default_ | определяет сеть из которой пользователь clickhouse по умолчанию может подключаться к базе данных. |
| _clickhouse_networks_custom_ | определяет сеть из которой определенные пользователи clickhouse могут подключаться к базе данных (например, пользователь vector). |
| _clickhouse_users_default_ | определяет пользователя по умолчанию у его настройки. |
| _clickhouse_users_custom_ | определяет иных пользователей и их настройки. |
| _clickhouse_profiles_default_ | определяет настройки профиля пользователя по умолчанию. |
| _clickhouse_profiles_custom_ | определяет настройки иных профилей пользователей по умолчанию. |
| _clickhouse_quotas_intervals_default_ | определяет набор базовых квот. |
| _clickhouse_quotas_default_ | определяет квоты пользователя по умолчанию. |
| _clickhouse_quotas_custom_ | определяет квоты иных пользователей. |
| _lighthouse_user_ | пользователь для подключения lighthouse. |
| _lighthouse_pass_ | пароль пользователя для подключения lighthouse. |
| _vector_user_ | пользователь для подключения vector. |
| _vector_pass_ | пароль пользователя для подключения vector. |

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

### Lighthouse variables

#### __Installation__

| variable | описание |
|:---|:---|
| _lighthouse_dist_ | ссылка на github с дистрибутивом. |
| _lighthouse_dir_ | директория, куда будет помещен дистрибутив. |

#### __Configuration__

| variable | описание |
|:---|:---|
| _nginx_user_name_ | пользователь nginx по умолчанию в nginx.conf файле.|
| _nginx_default_port_ | задает http порт nginx по умолчанию.|
| _lighthouse_port_ | задает http порт lighthouse по умолчанию.|

## Playbook tasks

___

### Clickhouse

Play `Install clickhouse` разворачивает Clickhouse на сервере, создает конфигурационные файлы для сервера и клиента, затем создается база данных для записи логов с хоста vector.  

__Clickhouse | Get distrib__ (Tag `get_clickhouse`) - скачивает пакеты clickhouse-server, clickhouse-client, clickhouse-common.\
__Clickhouse | Install packages__ (Tag `start_clickhouse`) - устанавливает Clickhouse.\
__Clickhouse | Generate users config__ (Tag `configure_clickhouse`) - создает users.xml конфигурационный файл на основе [clickhouse.users.j2](templates/clickhouse.users.j2) шаблона.\
__Clickhouse | Generate server config__ (Tag `configure_clickhouse`) - создает config.xml конфигурационный файл на основе[clickhouse.config.j2](templates/clickhouse.config.j2) шаблона.\
__Clickhouse | Create database and table__ (Tag `configure_clickhouse`) - создает тестовую базу данных (`logs`) и таблицу для логов vector. Также данная task определяет пользователей vector and lighthouse.\
__Start clickhouse service__ - handler, который стартует или перезапускает Clickhouse.

### Vector

Play `Install vector` разворачивает Vector на сервере, создает конфигурационный файл vector, затем запускает vector. С примененим конфигурационного файла передает из vector в базу данных clickhouse, созданную в предыдущем play.

__Vector | Install package__ (Tag `install_vector`) - создает директорию для пакета Vector.\
__Vector | Generate config__ (Tag `configure_vector`)- генерирует Vector .yml конфигурационный файл в директории /etc/vector на основании [vector.yml.j2](templates/vector.yml.j2) шаблона.\
__Vector | Configure service__ (Tag `configure_vector`) - создает vector.service на основании [vector.service.j2](templates/vector.service.j2) шаблона.\
__Start vector service__ - handler, который стартует или перезапускает Vector.

### Lighthouse

Play `Install nginx` разворачивает и конфигурирует nginx на сервере lighthouse. Play `Install lighthouse` скачивает дистрибутив lighthouse и запускает nginx service.

__Nginx | Install epel-release__ (Tag `get_nginx`) - устанавливает репозиторий EPEL для сервера Centos.\
__Nginx | Install nginx__ - (Tag `get_nginx`) - устанавливает nginx.\
__Nginx | Generate config__ (Tag `config_nginx`) - вносит изменения в файл конфигурации nginx.conf.\
__Start nginx service__ - handler, который стартует nginx.\
__Reload nginx service__ - handler, который перезагружает nginx после изменений в конфигурации.\
__Lighthouse | Install dependencies (git)__ (Tag `install_git`)- pre-task для установки git.\
__Lighthouse | Copy from git__ (Tag `get_lighthouse`) - скачивает lighthouse с github.\
__Lighthouse | Create config__ (Tag `configure_lighthouse`) - создает конфигурационный файл в директории nginx.

___