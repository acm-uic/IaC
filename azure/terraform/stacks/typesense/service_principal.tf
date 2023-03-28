resource "azuread_application" "terraform_typesense_deploy" {
  display_name = "terraform-typesense-deploy"
  owners       = var.additional_owner_ids # Azure AD Owner IDs
}

resource "azuread_service_principal" "terraform_typesense_deploy" {
  application_id               = azuread_application.terraform_typesense_deploy.application_id
  app_role_assignment_required = false
  owners                       = var.additional_owner_ids # Azure AD Owner IDs
}

resource "azurerm_role_assignment" "terraform_typesense_deploy" {
  scope                = azurerm_resource_group.typesense_rg.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.terraform_typesense_deploy.id
}

resource "azuread_application_federated_identity_credential" "terraform_typesense_deploy" {
  application_object_id = azuread_application.terraform_typesense_deploy.object_id
  display_name          = "terraform-typesense-deploy"
  description           = "https://github.com/acm-uic/acm-uic.github.io"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:acm-uic/acm-uic.github.io:environment:azure-container-app"
}

resource "github_actions_secret" "typesense_application_id" {
  repository      = "acm-uic.github.io"
  secret_name     = "AZURE_CLIENT_ID"
  plaintext_value = azuread_application.terraform_typesense_deploy.application_id
}

resource "github_actions_secret" "typesense_resource_group" {
  repository      = "acm-uic.github.io"
  secret_name     = "AZURE_RESOURCE_GROUP_NAME"
  plaintext_value = azurerm_resource_group.typesense_rg.name
}
