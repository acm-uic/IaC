data "azurerm_resource_group" "acm_hybridcloud_rg" {
  name = "acm-hybridcloud"
}

data "azurerm_storage_account" "acm_hybridcloud_storage_account" {
  name                = "acmhybridstore"
  resource_group_name = data.azurerm_resource_group.acm_hybridcloud_rg.name
}

resource "azuread_application" "terraform_typesense_deploy" {
  display_name = "terraform-typesense-deploy"
  owners       = var.additional_owner_ids # Azure AD Owner IDs
}

resource "azuread_service_principal" "terraform_typesense_deploy" {
  application_id               = azuread_application.terraform_typesense_deploy.application_id
  app_role_assignment_required = false
  owners                       = var.additional_owner_ids # Azure AD Owner IDs
}

resource "azurerm_role_assignment" "terraform_typesense_deploy_rg" {
  scope                = azurerm_resource_group.typesense_rg.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.terraform_typesense_deploy.id
}


resource "azurerm_role_assignment" "terraform_typesense_deploy_tfstate" {
  scope                = data.azurerm_storage_account.acm_hybridcloud_storage_account.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azuread_service_principal.terraform_typesense_deploy.id
}

resource "azuread_application_federated_identity_credential" "terraform_typesense_deploy_main" {
  application_object_id = azuread_application.terraform_typesense_deploy.object_id
  display_name          = "terraform-typesense-deploy-main"
  description           = "https://github.com/acm-uic/acm-uic.github.io"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:acm-uic/acm-uic.github.io:ref:main"
}

resource "azuread_application_federated_identity_credential" "terraform_typesense_deploy_pr" {
  application_object_id = azuread_application.terraform_typesense_deploy.object_id
  display_name          = "terraform-typesense-deploy-pr"
  description           = "https://github.com/acm-uic/acm-uic.github.io"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:acm-uic/acm-uic.github.io:pull_request"
}

resource "azuread_application_federated_identity_credential" "terraform_typesense_deploy_env" {
  application_object_id = azuread_application.terraform_typesense_deploy.object_id
  display_name          = "terraform-typesense-deploy-env"
  description           = "https://github.com/acm-uic/acm-uic.github.io"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:acm-uic/acm-uic.github.io:environment:azure-container-app"
}

output "azuread_application_terraform_typesense_deploy_object_id" {
  value = azuread_application.terraform_typesense_deploy.object_id
}
