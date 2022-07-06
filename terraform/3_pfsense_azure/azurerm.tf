# Create Service Principal
data "azuread_client_config" "current" {}

resource "azuread_application" "pfsense" {
  display_name = "${var.pfsense_namespace}ServiceApp"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "pfsense" {
  application_id               = azuread_application.pfsense.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
  description                  = "Service Principal for on-prem pfSense"
}

resource "azuread_service_principal_password" "pfsense" {
  display_name = "${var.pfsense_namespace}Password"
  service_principal_id = azuread_service_principal.pfsense.object_id
}

resource "azurerm_role_assignment" "pfsense_reader" {
  scope = "/subscriptions/${var.azure_subscription_id}/resourceGroups/acm-general/providers/Microsoft.Network/dnszones/${var.public_domain_suffixes[0]}"
  role_definition_name = "Reader"
  principal_id = azuread_service_principal.pfsense.object_id
}

resource "azurerm_role_assignment" "pfsense_contributor" {
  scope = "/subscriptions/${var.azure_subscription_id}/resourceGroups/acm-general/providers/Microsoft.Network/dnszones/${var.public_domain_suffixes[0]}"
  role_definition_name = "Contributor"
  principal_id = azuread_service_principal.pfsense.object_id
}

