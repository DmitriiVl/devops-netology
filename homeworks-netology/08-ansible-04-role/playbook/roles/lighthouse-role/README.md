Role Name
Lighthouse-role

This role install lighthouse.

Requirements
------------

This role has tested on:  

- CentOS 7

Required packages:

- git
- nginx

All these packages will be installed during play launching.

Role Variables
--------------

| Variable | Description | Default value | Location |
|------|------------|---|---|
|nginx_default_port|default nginx http port|`8009`|[defaults folder](defaults/main.yml)|
|lighthouse_port|default lighthouse http port|`9000`|[defaults folder](defaults/main.yml)|
|nginx_user_name|user for access and modify folders and files related to lighthouse|`nginx`|[vars folder](vars/main.yml)|
|lighthouse_vcs|lighthouse source|`https://github.com/VKCOM/lighthouse.git`|[vars folder](vars/main.yml)|
|lighthouse_dir|folder for lighthouse location|`/usr/share/lighthouse`|[vars folder](vars/main.yml)|

Example Playbook
----------------

- name: Install nginx
  hosts: lighthouse
  handlers:
  roles:
    - lighthouse-role

License
-------

MIT

Author Information
------------------

Role created by Dmitrii Vladimirov