# Vault Injector Terraform Stack

This Terraform stack will allow us to utilize secrets that are created/defined within various Terraform stacks within Vault. This stack acts as a bridge/injector for placing secrets within Vault.

## Requirements

- This stack must run within a worker what has access to a Vault endpoint.
- Environment variables (detailed below) must be pre-defined before running this Terraform stack.
- User must be logged into Azure using the `az login` command and have sufficient privileges to access the storage account used for Terraform backend state. 

## Environment variables

The following must be defined for the Terraform stack to run correctly.

- `VAULT_ADDR` - This is the URL used to access the Vault instance. (e.g.: `https://vault.acmuic.org`)
- `VAULT_TOKEN` - This is the token used to interact with the Vault API. This can be retrieved manually by logging in and copying the token from the web UI. If this is being run via automation, this does not need to be defined, but an additional auth method should be used. (e.g.: Kubernetes service accounts, AppRole, etc.)
