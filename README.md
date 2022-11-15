# Infrastructure as Code(IaC)
Restructuring of ACM/LUG's server infrastructure using Infrastructure as Code(IaC) methodologies.

## Folder structure

This repo is responsible for storing multiple aspect of ACM@UIC's infrastructure. As a result, multiple tools are utilized to handle various parts of the system.
The repo is split by major technologies to better organize the various codebases running.

### Overview

```
├── azure - This folder contains all IaC related to the Azure Cloud Platform.
│   └── terraform - This is where all Terraform code resides for Azure resources
│       └── stacks - This folder is a folder of folders, each subfolder contains Terraform stacks to deploy related resources
├── helm_charts - For Kubernetes, contains custom Helm Charts used to deploy to a K8s cluster
├── kubernetes - This folder contains the IaC related to Kubernetes resources
│   └── terraform - This is where all Terraform code resides for Kubernetes environments
│       └── stacks - This folder is a folder of folders, each subfolder contains Terraform stacks to deploy K8s applications
│   └── ansible - This is where all Ansible code resides for Kubernetes environments
│       └── playbooks - This folder is a folder of folders, each subfolder contains Ansible playbooks to deploy K8s apps
├── proxmox - The folder contains the IaC related to Proxmox resources
│   └── terraform - This is where all Terraform code resides for deploying VMs into Proxmox
│       └── stacks - This folder is a folder of folders, each subfolder contains Terraform stacks to deploy VMs and Proxmox resources
│   └── ansible - This is where all Ansible code resides for Proxmox hypervisors and VMs
│       └── playbooks - This folder is a folder of folders, each subfolder contains Ansible playbooks to deploy VMs and Proxmox resources
├── vsphere - This folder contains all IaC related to VMware ESXi / VSphere hypervisors
│   └── ansible - This is where all Ansible code resides for VSphere VM deployments
│       └── playbooks - This folder is a folder of folders, each subfolder contains Ansible playbooks to deploy VMs and VSphere resources
└── raspberrypi - This folder contains all IaC related to deployed Raspberry Pis
    └── ansible - This is where all Ansible code resides for deployed Raspberry Pis
        └── playbooks - This folder is a folder of folders, each subfolder contains Ansible playbooks to configure Raspberry Pis
```
