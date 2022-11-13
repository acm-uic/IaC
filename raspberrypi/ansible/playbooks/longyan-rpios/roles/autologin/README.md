Autologin
=========

This role sets up terminal autologin for systemd.

Requirements
------------

This role assumes you are using a system using systemd.

Role Variables
--------------

`user` - This is the name of the username that will be used for autologin.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.autologin, user: runner }

License
-------

MIT

Author Information
------------------

This role was originally created by Chase Lee as part of the IaC for the Association for Computing Machinery Student Chapter at the University of Illinois at Chicago. For more information, see the repo: https://github.com/acm-uic/IaC
