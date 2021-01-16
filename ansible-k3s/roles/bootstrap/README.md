Bootstrap
=========

This is a bootstrapping role to allow Ansible to be run on our machines. 

Requirements
------------

* Compatible OS:
  - CentOS 7+
  - Ubuntu 20.04 LTS
  - ArchLinux
* Using a service user with root privileges

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

No dependencies are required. The raw module is used for the majority of this role.

Example Playbook
----------------

Include this role as part of your main playbook. It should reside near the top of your main playbook:

    - hosts: servers
      gather_facts: false
      roles:
         - { role: bootstrap, x: 42 }

License
-------

BSD

Author Information
------------------

Written for the [ACM@UIC](https://acm.cs.uic.edu/) Student Organization. Enriching student lives for over 52 years!
Support can be found via our main GitHub repos: https://github.com/acm-uic
