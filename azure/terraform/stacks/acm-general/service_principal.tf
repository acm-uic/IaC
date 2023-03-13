data "azurerm_client_config" "current" {}

data "azurerm_subscription" "primary" {}


resource "azuread_application" "terraform_sysadmin_demo" {
  display_name = "terraform-sysadmindemo-svc"
  owners       = var.additional_owner_ids # Azure AD Owner IDs
}

resource "azuread_service_principal" "terraform_sysadmin_demo" {
  application_id               = azuread_application.terraform_sysadmin_demo.application_id
  app_role_assignment_required = false
  owners                       = var.additional_owner_ids # Azure AD Owner IDs
}

resource "azuread_application_password" "terraform_sysadmin_demo" {
  application_object_id = azuread_application.terraform_sysadmin_demo.object_id
  display_name          = "rbac-sysadmindemo-apppass"
  end_date_relative     = "240h"
}

resource "azurerm_role_assignment" "terraform_sysadmin_demo_reader" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.terraform_sysadmin_demo.id
}

resource "azurerm_role_assignment" "terraform_sysadmin_demo_dns" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azuread_service_principal.terraform_sysadmin_demo.id
}

