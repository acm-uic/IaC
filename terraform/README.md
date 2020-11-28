# ACM IaC - Terraform

This section of the repo is dedicated for the use of Terraform to deploy and manage software and configuration.


## Folder structure breakdown

| Folder Name | Description |
| ----------- | ----------- |
| configurations | Contains tfvars files used to provide environment variables and additional configuration for specific clusters. |
| 1_k8s_cluster_setup | Installs cluster controllers, daemonsets, etc required for bare-metal cluster operation |
| 2_k8s_cluster_apps | Installs cluster apps for member usage |
