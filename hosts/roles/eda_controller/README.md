# EDA Controller

This role will setup EDA Controller on the designated host.

Example:

```
- name: configure private automation hub
  hosts: eda_controllres
  gather_facts: true
  become: true
  tasks:
    - include_role:
        name: eda_controller
```
