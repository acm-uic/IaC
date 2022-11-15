Doorbot Discord Install
=========

This role installs the doorbot-discord on a system

Requirements
------------

The user that this application is being run under must be created beforehand.

Role Variables
--------------

`runner_username` - This is the unix user that the application will be running under.

Dependencies
------------

This program expects an installed and working version of the doorkeeper_controller on the system.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.doorbot_install, runner_username: acmrunner }

License
-------

MIT

Author Information
------------------

This role was originally created as part of the IaC for the Association for Computing Machinery Student Chapter at the University of Illinois at Chicago. For more information, see the repo: https://github.com/acm-uic/IaC
