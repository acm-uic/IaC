# https://github.com/acmesh-official/acme.sh/wiki/How-to-use-Azure-DNS
#
# This is a service principal that is used by PFSense to manage DNS records
# for the ACME challenges.


# az ad sp create-for-rbac --name pfsenseServiceApp --role "DNS Zone Contributor" --scopes /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/acme-general/providers/Microsoft.Network/dnszones/acme.chase.net

resource "azuread_application" "pfsense" {
  display_name = "pfsenseServiceApp"
  owners       = var.additional_owner_ids
}

resource "azuread_service_principal" "pfsense" {
  client_id   = azuread_application.pfsense.client_id
  description = "Service Principal for on-prem pfSense"
  owners      = var.additional_owner_ids
}

resource "azuread_service_principal_password" "pfsense" {
  service_principal_id = azuread_service_principal.pfsense.id
  display_name         = "pfsensePassword"
}

# Lookup existing role asisgnments
# `az role assignment list --all | grep "<principal_id>" -B10 -A10`
resource "azurerm_role_assignment" "pfsense_dns_contributor" {
  scope                = data.azurerm_dns_zone.acmuic_org.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azuread_service_principal.pfsense.object_id
}

output "pfsense_service_principal_id" {
  value = azuread_service_principal.pfsense.id
}

output "pfsense_service_principal_password" {
  value = azuread_service_principal_password.pfsense.value
  sensitive = true
}
