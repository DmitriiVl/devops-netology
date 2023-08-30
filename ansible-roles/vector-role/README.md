ansible-vector
=========

Simple vector deploy role with clickhouse connection example.

Requirements
------------

This role has tested on:

- Debian 11

Role Variables
--------------

| Variable | Description | Default value | Location |
|------|------------|---|---|
|vector_config|specifies vector settings for connection to clickhouse server|`see example below this table`|[defaults folder](defaults/main.yml)|
|clickhouse_source|url of clickhouse server|`http://192.168.150.10:8123`|[defaults folder](defaults/main.yml)|
|vector_version|version package vector|`0.25.1`|[vars folder](vars/main.yml)|
|vector_package|package name|`vector`|[vars folder](vars/main.yml)|
|vector_architecture|package's processor architecture|`amd64`|[vars folder](vars/main.yml)|
|vector_config_dir|default folder of vector config|`/etc/vector`|[vars folder](vars/main.yml)|

Here is an example of vector configuration:

    vector_config:
      sources:
        sample_file:
          type: file
          read_from: beginning
          include:
            # using syslog as an example
            - /var/log/syslog
      sinks:
        to_clickhouse:
          type: clickhouse
          inputs:
            # 'sample_file' from 'sources' above
            - sample_file
          database: logs
          # clickhouse URL
          endpoint: "{{ clickhouse_source }}"
          table: vector_logs
          # example of user with plain-defined password in clickhouse DBMS
          auth:
            strategy: basic
            user: vector
            password: vector
          healthcheck: true
          skip_unknown_fields: true
          compression: gzip

Dependencies
------------

This role has no required dependencies.

Example Playbook
----------------

    - name: Install vector
      hosts: vector
      roles:
        - vector

License
-------

MIT

Author Information
------------------

[Vector](https://vector.dev/docs/) by [Datadog](https://www.datadoghq.com/).

Role created by Stanislav Gurniak\
<https://github.com/vainoord>\
<https://gitlab.com/vainoord>
