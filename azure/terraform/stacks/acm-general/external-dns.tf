# Create Service Principal for ExternalDNS
data "azuread_client_config" "current" {}
data "azurerm_subscription" "current" {}

resource "azuread_application" "externaldns" {
  display_name = "${var.external_dns_namespace}ServiceApp"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "externaldns" {
  application_id               = azuread_application.externaldns.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
  description                  = "Service Principal for ExternalDNS within on-prem Kubernetes"
}

resource "azuread_service_principal_password" "externaldns" {
  display_name         = "${var.external_dns_namespace}Password"
  service_principal_id = azuread_service_principal.externaldns.object_id
}

resource "azurerm_role_assignment" "externaldns_reader" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/acm-general/providers/Microsoft.Network/dnszones/${var.public_domain_suffixes[0]}"
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.externaldns.object_id
}

resource "azurerm_role_assignment" "externaldns_contributor" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/acm-general/providers/Microsoft.Network/dnszones/${var.public_domain_suffixes[0]}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.externaldns.object_id
}

output "externaldns_sp_keyid" {
  value = azuread_service_principal_password.externaldns.key_id
}

output "externaldns_sp_password" {
  value     = azuread_service_principal_password.externaldns.value
  sensitive = true
}
