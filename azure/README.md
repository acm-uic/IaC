# Azure - Cloud Infrastructure

This setup is to allow automated provisioning of the ACM@UIC's cloud services.  The main goal of this project is to maintain and deploy the majority of our infrastructure with minimal setup.

The idea is to define Infrastructure as Code (IAC). This allows DevOps and SysAdmin Engineers to easily understand configuration in a uniform way.

## Requirements

* CI/CD Platform (GitHub Actions)

## Pre-setup

The CI/CD platform will need to be configured with the appropriate authorization to make changes to the cloud infrastructure. 
This must be done before pipelines can run. Note that this needs to be only performed once per cloud tenant.

In Azure, these are setup by creating a Service Principal with role-based authentication control. [Reference documentation](https://learn.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create-for-rbac)
Using the CLI is the quickest way to perform this action.
Assuming you are already logged into the CLI, you can run the following invocation to create the Service Principal

```bash
# Create Service Principal and configure its access to Azure resources.
az ad sp create-for-rbac --name terraform-svc
```

This should result in a response similar to this:
```bash
$ az ad sp create-for-rbac --name terraform-svc
The output includes credentials that you must protect. Be sure that you do not include these credentials in your code or check the credentials into your source control. For more information, see https://aka.ms/azadsp-cli
{
  "appId": "00XXXXXX-XXXX-XXXX-xxxx-XXXXXXXXXX",
  "displayName": "terraform-svc",
  "password": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  "tenant": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}
```

Once the service principal is created, store the following secrets in your CI/CD platform:
* `AZURE_AD_CLIENT_ID` – This will be the `appId` from above
* `AZURE_AD_CLIENT_SECRET` – This will be the `password` from above
* `AZURE_AD_TENANT_ID` – The Azure AD tenant ID to where the service principal was created. This is the `tenant` from above.
* `AZURE_SUBSCRIPTION_ID` – Subscription ID of where you want to deploy the Terraform. This can be found in the output of `az account subscription list`.

Once the secrets are in place, ensure the appropriate pipelines have permission to access these secrets.
They can usually be defined as environment variables for use by the pipelines.

## Stack Inventory

This is a quick summary of each stack for the Azure Cloud Platform.

| Type      | Name        | Description                                          |
|-----------|-------------|------------------------------------------------------|
| Terraform | acm-general | Deploys the assets in the acm-general resource group |
