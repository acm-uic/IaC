# Kubernetes Cluster Bootstrap Setup

## Required Variables

The following environment variables need to be present before deployment:

- `TF_VAR_deploy_key` - This is the deployment SSH key used for accessing Github repos.

- `KUBE_CONFIG_PATH` - This is the absolute filepath pointing to the kubeconfig file used to auth to the cluster. 

## Manual Terraform Deployment

```bash
terraform init
terraform plan -var-file configurations/acmapp_prod.tfvars
terraform apply -var-file configurations/acmapp_prod.tfvars
```
