# PIRouter

## Prerequisites

- Ansible 2.9.x
- Python 3.x
- Raspberry Pi with Debian pre-installed and SSH enabled
  - A user with sudo privileges should be created

## Usage

### Install

```bash
ansible-galaxy install -r requirements.yml
```

### Run

```bash
ansible-playbook -i inventory.yml main.yml --ask-pass
```
