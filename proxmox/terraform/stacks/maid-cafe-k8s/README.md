# Proxmox VM Deployment

This Terraform project deploys a virtual machine to a Proxmox cluster.

## Prerequisites

- Terraform installed (version 1.0.0+)
- Access to a Proxmox cluster
- API token for Proxmox authentication

## Setup

1. Create a copy of `terraform.tfvars.example` as `terraform.tfvars`:
   ```
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your Proxmox cluster details:
   - Update API URL and credentials
   - Configure VM specifications
   - Add your SSH public key

## Usage

Initialize the Terraform project:
```
terraform init
```

Plan the deployment:
```
terraform plan
```

Apply the configuration:
```
terraform apply
```

Destroy the resources when no longer needed:
```
terraform destroy
```

## Variables

See `variables.tf` for a complete list of configurable parameters.

## Notes

- The VM will be deployed using cloud-init from a template
- Default network configuration uses DHCP
- SSH access is configured with the provided public key