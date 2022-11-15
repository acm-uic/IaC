Doorkeeper Install
=========

This role installs and configures the doorkeeper to run on a machine for a given runner user.

Requirements
------------

The user that this application runs under must already be created.

Role Variables
--------------

`runner_username` - This is the Unix username of the user that we will be installing the application under.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.doorkeeper_install, runner_username: acmrunner }

License
-------

MIT

Author Information
------------------

This role was originally created by Chase Lee as part of the IaC for the Association for Computing Machinery Student Chapter at the University of Illinois at Chicago. For more information, see the repo: https://github.com/acm-uic/IaC

