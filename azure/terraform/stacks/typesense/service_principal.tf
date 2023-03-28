resource "azuread_application" "terraform_typesense_deploy" {
  display_name = "terraform-typesense-deploy"
  owners       = var.additional_owner_ids # Azure AD Owner IDs
}

resource "azuread_service_principal" "terraform_typesense_deploy" {
  application_id               = azuread_application.terraform_typesense_deploy.application_id
  app_role_assignment_required = false
  owners                       = var.additional_owner_ids # Azure AD Owner IDs
}

resource "azuread_application_password" "terraform_typesense_deploy" {
  application_object_id = azuread_application.terraform_typesense_deploy.object_id
  display_name          = "rbac-sysadmindemo-apppass"
}

resource "azurerm_role_assignment" "terraform_typesense_deploy" {
  scope                = azurerm_resource_group.typesense_rg.id
  role_definition_name = "Contributer"
  principal_id         = azuread_service_principal.terraform_typesense_deploy.id
}

resource "azurerm_federated_identity_credential" "example" {
  name                = "terraform-typesense-deploy"
  resource_group_name = azurerm_resource_group.typesense_rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azuread_application.terraform_typesense_deploy.id
  subject             = "repo:acm-uic/acm-uic.github.io:environment:azure-container-app"
}
