Vector Role
=========

This role can install Vector

Requirements
------------

This role has tested on:  

- CentOS 7

Role Variables
--------------

| Variable | Description | Default value | Location |
|------|------------|---|---|
|vector_config|specifies vector settings for connection to clickhouse server|`see example below this table`|[defaults folder](defaults/main.yml)|
|vector_version|version package vector|`0.25.1`|[vars folder](defaults/main.yml)|
|vector_package|package name|`vector`|[vars folder](vars/main.yml)|
|vector_architecture|package's processor architecture|`amd64`|[vars folder](vars/main.yml)|
|vector_config_dir|default folder of vector config|`/etc/vector`|[vars folder](vars/main.yml)|

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

Role created by Dmitrii Vladimirov